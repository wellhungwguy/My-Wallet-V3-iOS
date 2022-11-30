// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import ComposableArchitecture
import FeatureCardIssuingDomain
import Localization
import SwiftUI
import ToolKit

struct CardIssuingIntroView: View {

    private typealias L10n = LocalizationConstants.CardIssuing.Order

    let store: Store<CardOrderingState, CardOrderingAction>
    @State private var isNextScreenVisible = false

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(spacing: Spacing.padding3) {
                Image("graphic-cards", bundle: .cardIssuing)
                    .resizable()
                    .scaledToFit()
                Text(L10n.Intro.title)
                    .typography(.title2)
                    .multilineTextAlignment(.center)
                Text(L10n.Intro.caption)
                    .typography(.paragraph1)
                    .foregroundColor(.WalletSemantic.body)
                    .multilineTextAlignment(.center)
                PrimaryButton(
                    title: L10n.Intro.Button.Title.order,
                    isLoading: false,
                    action: {
                        isNextScreenVisible = true
                    }
                )
                PrimaryNavigationLink(
                    destination: nextView(),
                    isActive: $isNextScreenVisible,
                    label: EmptyView.init
                )
                .padding(.top, Spacing.padding2)
                Spacer()
                Text(L10n.Intro.fullDisclaimer)
                    .multilineTextAlignment(.center)
                    .typography(.caption1)
                    .foregroundColor(.semantic.muted)
            }
            .onAppear {
                viewStore.send(.fetchProducts)
                viewStore.send(.fetchLegalItems)
            }
            .padding(Spacing.padding3)
            .primaryNavigation(title: LocalizationConstants.CardIssuing.Navigation.title)
        }
    }
}

extension CardIssuingIntroView {

    @ViewBuilder
    private func nextView() -> some View {
        WithViewStore(store) { viewStore in
            switch viewStore.state.initialKyc.status {
            case .success:
                ProductSelectionView(store: store)
            default:
                ResidentialAddressConfirmationView(store: store)
            }
        }
    }
}

#if DEBUG
struct CardIssuingIntro_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CardIssuingIntroView(
                store: Store(
                    initialState: .init(
                        initialKyc: KYC(status: .success, errorFields: nil)
                    ),
                    reducer: cardOrderingReducer,
                    environment: .preview
                )
            )
            CardIssuingIntroView(
                store: Store(
                    initialState: .init(
                        initialKyc: KYC(status: .success, errorFields: nil)
                    ),
                    reducer: cardOrderingReducer,
                    environment: .preview
                )
            )
        }
    }
}
#endif
