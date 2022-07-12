// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import BlockchainComponentLibrary
import ComposableArchitecture
import Localization
import MoneyKit
import SwiftUI
import UIComponentsKit

enum TradingCurrency {

    struct State: Equatable {
        var displayCurrency: FiatCurrency
        var currencies: [FiatCurrency]
    }

    enum Action: Equatable {
        case close
        case didSelect(FiatCurrency)
    }

    struct Environment {
        let closeHandler: () -> Void
        let selectionHandler: (FiatCurrency) -> Void
        let analyticsRecorder: AnalyticsEventRecorderAPI
    }

    static let reducer = Reducer<State, Action, Environment> { _, action, env in
        switch action {
        case .close:
            return .fireAndForget {
                env.closeHandler()
            }

        case .didSelect(let fiatCurrency):
            return .fireAndForget {
                env.selectionHandler(fiatCurrency)
            }
        }
    }
    .analytics()
}

struct TradingCurrencySelector: View {

    private typealias LocalizedStrings = LocalizationConstants.Transaction.TradingCurrency

    let store: Store<TradingCurrency.State, TradingCurrency.Action>

    var body: some View {
        WithViewStore(store) { viewStore in
            ModalContainer(onClose: viewStore.send(.close)) {
                VStack(spacing: Spacing.padding3) {
                    Icon.globe
                        .accentColor(.semantic.primary)
                        .frame(width: 32, height: 32)

                    VStack(spacing: Spacing.baseline) {
                        Text(LocalizedStrings.screenTitle)
                            .typography(.title2)

                        Text(
                            LocalizedStrings.screenSubtitle(
                                displayCurrency: viewStore.displayCurrency.name
                            )
                        )
                        .typography(.paragraph1)
                    }
                    .padding(.horizontal, Spacing.padding3)

                    ScrollView {
                        LazyVStack {
                            ForEach(viewStore.currencies, id: \.code) { currency in
                                PrimaryDivider()
                                PrimaryRow(
                                    title: currency.name,
                                    subtitle: currency.displayCode,
                                    action: {
                                        viewStore.send(.didSelect(currency))
                                    }
                                )
                            }
                        }
                    }

                    Text(LocalizedStrings.disclaimer)
                        .typography(.micro)
                        .foregroundColor(.semantic.body)
                        .padding(.horizontal, Spacing.padding3)

                    Spacer()
                }
                .multilineTextAlignment(.center)
            }
        }
    }
}

// MARK: SwiftUI Previews

#if DEBUG

struct TradingCurrencySelector_Previews: PreviewProvider {

    static var previews: some View {
        TradingCurrencySelector(
            store: .init(
                initialState: .init(
                    displayCurrency: .JPY,
                    currencies: MoneyKit.allEnabledFiatCurrencies
                ),
                reducer: TradingCurrency.reducer,
                environment: .init(
                    closeHandler: {},
                    selectionHandler: { _ in },
                    analyticsRecorder: NoOpAnalyticsRecorder()
                )
            )
        )
    }
}

#endif
