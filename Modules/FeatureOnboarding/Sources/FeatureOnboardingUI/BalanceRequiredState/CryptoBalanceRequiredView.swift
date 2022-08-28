// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import ComposableArchitecture
import Localization
import SwiftUI
import UIComponentsKit

private typealias LocalizedStrings = LocalizationConstants.Onboarding.CryptoBalanceRequired

public enum CryptoBalanceRequired {

    public enum Action {
        case close
        case buyCrypto
        case requestCrypto
    }

    public struct Environment {
        /// A closure that dismisses the view
        let close: () -> Void
        /// A closure that presents the Buy Flow from the top-most view controller on screen and automatically dismissed the presented flow when done.
        let presentBuyFlow: () -> Void
        /// A closure that presents the Receive Crypto Flow from the top-most view controller on screen and automatically dismissed the presented flow when done.
        let presentRequestCryptoFlow: () -> Void

        public init(
            close: @escaping () -> Void,
            presentBuyFlow: @escaping () -> Void,
            presentRequestCryptoFlow: @escaping () -> Void
        ) {
            self.close = close
            self.presentBuyFlow = presentBuyFlow
            self.presentRequestCryptoFlow = presentRequestCryptoFlow
        }
    }

    public static let reducer = Reducer<
        Void, Action, Environment
    > { _, action, environment in
        switch action {
        case .close:
            return .fireAndForget {
                environment.close()
            }

        case .buyCrypto:
            return .fireAndForget {
                environment.presentBuyFlow()
            }

        case .requestCrypto:
            return .fireAndForget {
                environment.presentRequestCryptoFlow()
            }
        }
    }
}

public struct CryptoBalanceRequiredView: View {

    public let store: Store<Void, CryptoBalanceRequired.Action>

    public init(store: Store<Void, CryptoBalanceRequired.Action>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            ModalContainer(
                title: LocalizedStrings.title,
                subtitle: LocalizedStrings.subtitle,
                onClose: { viewStore.send(.close) },
                topAccessory: {
                    Image("crypto_required_header", bundle: .onboarding)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity, maxHeight: 200)
                },
                content: {
                    VStack(spacing: Spacing.padding3) {
                        VStack(alignment: .leading, spacing: Spacing.baseline) {
                            OnboardingChecklistRow(item: .buyCryptoAlternative, status: .incomplete)
                                .onTapGesture {
                                    viewStore.send(.buyCrypto)
                                }

                            OnboardingChecklistRow(item: .requestCrypto, status: .incomplete)
                                .onTapGesture {
                                    viewStore.send(.requestCrypto)
                                }
                        }

                        Spacer()
                    }
                    .padding(.horizontal, Spacing.padding3)
                }
            )
        }
    }
}

struct CryptoBalanceRequiredView_Previews: PreviewProvider {

    static var previews: some View {
        CryptoBalanceRequiredView(
            store: .init(
                initialState: (),
                reducer: CryptoBalanceRequired.reducer,
                environment: CryptoBalanceRequired.Environment(
                    close: {},
                    presentBuyFlow: {},
                    presentRequestCryptoFlow: {}
                )
            )
        )
    }
}
