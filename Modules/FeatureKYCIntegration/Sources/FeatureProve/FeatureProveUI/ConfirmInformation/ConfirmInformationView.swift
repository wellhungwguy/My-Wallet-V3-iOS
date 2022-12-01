// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import ComposableArchitecture
import DIKit
import ErrorsUI
import FeatureFormDomain
import FeatureFormUI
import Localization
import SwiftUI
import UIComponentsKit

struct ConfirmInformationView: View {

    private typealias LocalizedString = LocalizationConstants.ConfirmInformation

    @ObservedObject private var viewStore: ViewStore<ConfirmInformation.State, ConfirmInformation.Action>

    init(store: StoreOf<ConfirmInformation>) {
        self.viewStore = ViewStore(store)
    }

    var body: some View {
        Group {
            if viewStore.isLoading {
                LoadingStateView(title: LocalizedString.loadingTitle)
            } else if let uxError = viewStore.uxError {
                makeError(uxError: uxError)
            } else {
                content
            }
        }
        .primaryNavigation(
            title: viewStore.title,
            trailing: {
                if viewStore.uxError == nil {
                    IconButton(icon: .closeCirclev2) {
                        viewStore.send(.onClose)
                    }
                    .frame(width: 24.pt, height: 24.pt)
                } else {
                    EmptyView()
                }
            }
        )
        .hideBackButtonTitle()
        .navigationBarBackButtonHidden()
        .onAppear {
            viewStore.send(.onAppear)
        }
    }

    private var content: some View {
        Group {
            Spacer(minLength: 24.0)
            PrimaryForm(
                form: viewStore.binding(\.$form),
                submitActionTitle: LocalizedString.Buttons.continueTitle,
                submitActionLoading: viewStore.isLoading,
                submitAction: {
                    viewStore.send(.onContinue)
                },
                submitButtonMode: .onlyEnabledWhenAllAnswersValid,
                submitButtonLocation: .attachedToBottomOfScreen,
                fieldConfiguration: { answer in
                        .init(
                            textAutocorrectionType: .no,
                            onFieldTapped: onFieldTapped(answerId: answer.id),
                            bottomButton: fieldBottomButton(answerId: answer.id)
                        )
                },
                headerIcon: {
                    headerIcon
                }
            )
        }
    }

    private func onFieldTapped(answerId: String) -> (() -> Void)? {
        let isEmptyAddressAnswer = answerId == ConfirmInformation.InputField.emptyAddressAnswerId
        let isSingleAddressAnswer = answerId == ConfirmInformation.InputField.address.rawValue
        if isEmptyAddressAnswer {
            return {
                UIApplication.shared.endEditing()
                viewStore.send(.onEmptyAddressFieldTapped)
            }
        } else if isSingleAddressAnswer {
            return {
                UIApplication.shared.endEditing()
                viewStore.send(.onStartEditingSelectedAddress)
            }
        }
        return nil
    }

    private func fieldBottomButton(answerId: String) -> FieldConfiguation.BottomButton? {
        let isEmptyAddressAnswer = answerId == ConfirmInformation.InputField.emptyAddressAnswerId
        let isSingleAddressAnswer = answerId == ConfirmInformation.InputField.address.rawValue
        let isMultiAddressAnswer = answerId == ConfirmInformation.InputField.addressAnswerId(index: 0)
        return isEmptyAddressAnswer || isSingleAddressAnswer || isMultiAddressAnswer
        ? .init(
            leadingPrefixText: LocalizedString.Buttons.enterAddressManuallyPrefix,
            title: LocalizedString.Buttons.enterAddressManuallyTitle,
            action: {
                UIApplication.shared.endEditing()
                viewStore.send(.onEnterAddressManuallyTapped)
            }
        )
        : nil
    }

    private func makeError(uxError: UX.Error) -> some View {
        ErrorView(
            ux: uxError,
            dismiss: {
                viewStore.send(.onDismissError)
            }
        )
    }

    var headerIcon: some View {
        Icon.user
            .color(.semantic.primary)
            .frame(width: 32.pt, height: 32.pt)
    }
}

struct ConfirmInformation_Previews: PreviewProvider {

    static var previews: some View {
        let app: AppProtocol = resolve()
        Group {
            BeginVerificationView(store: .init(
                initialState: .init(),
                reducer: BeginVerification.preview(app: app)
            )).app(app)
        }
    }
}

extension UIApplication {
    fileprivate func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
