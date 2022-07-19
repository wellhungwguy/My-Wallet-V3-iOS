// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import ComposableArchitecture
import FeatureCardIssuingDomain
import Localization
import SwiftUI
import ToolKit

struct ResidentialAddressModificationView: View {

    private typealias L10n = LocalizationConstants.CardIssuing.Order.KYC

    private let store: Store<
        ResidentialAddressModificationState,
        ResidentialAddressModificationAction
    >

    init(
        store: Store<
            ResidentialAddressModificationState,
            ResidentialAddressModificationAction
        >
    ) {
        self.store = store
    }

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(spacing: Spacing.padding3) {
                VStack(spacing: Spacing.padding1) {
                    Input(
                        text: viewStore.binding(\.$line1),
                        isFirstResponder: viewStore
                            .binding(\.$selectedInputField)
                            .equals(.line1),
                        label: L10n.Address.Form.addressLine1,
                        placeholder: L10n.Address.Form.Placeholder.line,
                        state: viewStore.state.line1.isEmpty ? .error : .default,
                        configuration: {
                            $0.textContentType = .streetAddressLine1
                        },
                        onReturnTapped: {
                            viewStore.send(.binding(.set(\.$selectedInputField, .line2)))
                        }
                    )
                    Input(
                        text: viewStore.binding(\.$line2),
                        isFirstResponder: viewStore
                            .binding(\.$selectedInputField)
                            .equals(.line2),
                        label: L10n.Address.Form.addressLine2,
                        placeholder: L10n.Address.Form.Placeholder.line,
                        configuration: {
                            $0.textContentType = .streetAddressLine2
                        },
                        onReturnTapped: {
                            viewStore.send(.binding(.set(\.$selectedInputField, .city)))
                        }
                    )
                    Input(
                        text: viewStore.binding(\.$city),
                        isFirstResponder: viewStore
                            .binding(\.$selectedInputField)
                            .equals(.city),
                        label: L10n.Address.Form.city,
                        state: viewStore.state.city.isEmpty ? .error : .default,
                        configuration: {
                            $0.textContentType = .addressCity
                        },
                        onReturnTapped: {
                            viewStore.send(.binding(.set(\.$selectedInputField, .state)))
                        }
                    )
                    HStack(spacing: Spacing.padding2) {
                        Input(
                            text: viewStore.binding(\.$state),
                            isFirstResponder: viewStore
                                .binding(\.$selectedInputField)
                                .equals(.state),
                            label: L10n.Address.Form.state,
                            placeholder: L10n.Address.Form.Placeholder.state,
                            state: viewStore.state.state.isEmpty ? .error : .default,
                            configuration: {
                                $0.textContentType = .addressState
                            },
                            onReturnTapped: {
                                viewStore.send(.binding(.set(\.$selectedInputField, .zip)))
                            }
                        )
                        Input(
                            text: viewStore.binding(\.$postcode),
                            isFirstResponder: viewStore
                                .binding(\.$selectedInputField)
                                .equals(.zip),
                            label: L10n.Address.Form.zip,
                            state: viewStore.state.postcode.isEmpty ? .error : .default,
                            configuration: {
                                $0.textContentType = .postalCode
                            },
                            onReturnTapped: {
                                viewStore.send(.binding(.set(\.$selectedInputField, nil)))
                            }
                        )
                    }
                    Input(
                        text: .constant(countryName(viewStore.state.country)),
                        isFirstResponder: .constant(false),
                        label: L10n.Address.Form.country
                    )
                    .disabled(true)
                }
                .padding(.horizontal, Spacing.padding3)
                Spacer()
                PrimaryButton(
                    title: L10n.Buttons.save,
                    isLoading: viewStore.state.loading
                ) {
                    viewStore.send(.updateAddress)
                }
                .disabled(
                    viewStore.state.line1.isEmpty
                        || viewStore.state.postcode.isEmpty
                        || viewStore.state.city.isEmpty
                        || viewStore.state.state.isEmpty
                )
                .padding(Spacing.padding3)
                .padding(.bottom, Spacing.padding4)
            }
            .padding(.vertical, Spacing.padding3)
            .primaryNavigation(title: L10n.Address.Navigation.title)
            .onAppear {
                viewStore.send(.onAppear)
            }
            .bottomSheet(
                isPresented: viewStore.binding(
                    get: { $0.error != nil },
                    send: ResidentialAddressModificationAction.closeError
                ),
                content: {
                    IfLetStore(store.scope(state: \.error)) { store in
                        WithViewStore(store) { viewStore in
                            ErrorView(
                                title: viewStore.state.displayTitle,
                                description: viewStore.state.displayDescription,
                                cancelTitle: L10n.Buttons.cancel,
                                isModal: true,
                                cancelAction: {
                                    viewStore.send(
                                        ResidentialAddressModificationAction
                                            .closeError
                                    )
                                }
                            )
                        }
                    }
                }
            )
        }
    }
}

func countryName(_ code: String) -> String {
    let locale = NSLocale.current as NSLocale
    return locale.displayName(forKey: NSLocale.Key.countryCode, value: code) ?? ""
}

#if DEBUG
struct ResidentialAddressModification_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ResidentialAddressModificationView(
                store: Store(
                    initialState: .init(address: MockServices.address, error: .unknown),
                    reducer: residentialAddressModificationReducer,
                    environment: .init(
                        mainQueue: .main,
                        residentialAddressService: MockServices()
                    )
                )
            )
        }
    }
}
#endif
