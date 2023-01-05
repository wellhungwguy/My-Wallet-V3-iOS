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

struct EnterFullInformationView: View {

    private typealias LocalizedString = LocalizationConstants.EnterFullInformation

    @ObservedObject private var viewStore: ViewStore<EnterFullInformation.State, EnterFullInformation.Action>

    init(store: StoreOf<EnterFullInformation>) {
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
                submitButtonLocation: .attachedToBottomOfScreen(
                    footerText: LocalizedString.Footer.title,
                    hasDivider: true
                ),
                fieldConfiguration: { fieldId in
                    switch fieldId {
                    case EnterFullInformation.InputField.phone.rawValue:
                        return .phoneField
                    default:
                        return .init(textAutocorrectionType: .no)
                    }
                },
                headerIcon: {
                    headerIcon
                }
            )
        }
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

struct EnterFullInformation_Previews: PreviewProvider {

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

extension FieldConfiguation {
    fileprivate static let phoneField: FieldConfiguation = {
        .init(
            textAutocorrectionType: .no,
            keyboardType: .phonePad,
            textContentType: .telephoneNumber,
            inputPrefixConfig: .init(typography: .bodyMono, textColor: .semantic.title, spacing: 6),
            onTextChange: String.phoneWithoutCountryCode(phone:)
        )
    }()
}

extension String {
    fileprivate static func phoneWithoutCountryCode(phone: String) -> String {
        guard phone.contains("+") else { return phone }
        if phone.count == 1 { return "" }

        var totalCharacters: Int = 0
        var totalDigits: Int = 0
        // all mobile phones has 10 digits, we count 10 digits from the end
        // add take only characters with these 10 digits using suffix
        for element in phone.reversed() {
            totalCharacters += 1
            if element.isNumber {
                totalDigits += 1
            }
            if totalDigits == 10 {
                break
            }
        }
        // add missing "(" if neded
        if phone.suffix(totalCharacters + 1).first == "(" {
            totalCharacters += 1
        }

        return String(phone.suffix(totalCharacters))
    }
}
