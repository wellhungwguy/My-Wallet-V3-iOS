// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import Combine
import ComposableArchitecture
import ComposableArchitectureExtensions
import FeatureCoinDomain
import Localization
import SwiftUI
import ToolKit

public let coinViewReducer = Reducer<
    CoinViewState,
    CoinViewAction,
    CoinViewEnvironment
>.combine(
    graphViewReducer
        .pullback(
            state: \.graph,
            action: /CoinViewAction.graph,
            environment: { $0 }
        ),
    .init { state, action, environment in
        switch action {

        case .onAppear:
            state.appMode = environment.app.currentMode

            return .merge(
                Effect(value: .observation(.start)),

                Effect(value: .refresh),

                environment.assetInformationService
                    .fetch()
                    .receive(on: environment.mainQueue)
                    .catchToEffect()
                    .map(CoinViewAction.fetchedAssetInformation),

                environment.app.publisher(
                    for: blockchain.ux.asset[state.currency.code].watchlist.is.on,
                    as: Bool.self
                )
                .compactMap(\.value)
                .receive(on: environment.mainQueue)
                .eraseToEffect()
                .map(CoinViewAction.isOnWatchlist),

                NotificationCenter.default
                    .publisher(for: .transaction)
                    .receive(on: environment.mainQueue)
                    .eraseToEffect()
                    .map { _ in .refresh },

                environment.app.on(blockchain.ux.asset[state.currency.code].refresh)
                    .receive(on: environment.mainQueue)
                    .eraseToEffect()
                    .map { _ in .refresh },

                .fireAndForget { [state] in
                    environment.app.post(event: blockchain.ux.asset[state.currency.code])
                }
            )

        case .onDisappear:
            return Effect(value: .observation(.stop))

        case .refresh:
            return environment.kycStatusProvider()
                .setFailureType(to: Error.self)
                .combineLatest(
                    environment.accountsProvider().flatMap(\.snapshot)
                )
                .receive(on: environment.mainQueue.animation(.spring()))
                .catchToEffect()
                .map(CoinViewAction.update)

        case .fetchInterestRate:
            return environment.interestRatesRepository
                .fetchRate(code: state.currency.code)
                .result()
                .receive(on: environment.mainQueue)
                .eraseToEffect()
                .map(CoinViewAction.fetchedInterestRate)

        case .fetchedInterestRate(let result):
            state.interestRate = try? result.get()
            return .none

        case .fetchedAssetInformation(let result):
            state.assetInformation = try? result.get()
            return .none

        case .isOnWatchlist(let isFavorite):
            state.isFavorite = isFavorite
            return .none

        case .addToWatchlist:
            state.isFavorite = nil
            return .fireAndForget { [state] in
                environment.app.post(
                    event: blockchain.ux.asset[state.currency.code].watchlist.add
                )
            }

        case .removeFromWatchlist:
            state.isFavorite = nil
            return .fireAndForget { [state] in
                environment.app.post(
                    event: blockchain.ux.asset[state.currency.code].watchlist.remove
                )
            }

        case .update(let update):
            switch update {
            case .success(let result):
                let (kycStatus, accounts) = result
                state.kycStatus = kycStatus
                state.accounts = accounts
                if let account = state.account {
                    state.account = state.accounts.first(where: { snapshot in snapshot.id == account.id })
                }
                let update = Effect<CoinViewAction, Never>.fireAndForget {
                    environment.app.state.transaction { state in
                        for account in accounts {
                            state.set(blockchain.ux.asset.account[account.id].is.trading, to: account.accountType == .trading)
                            state.set(blockchain.ux.asset.account[account.id].is.private_key, to: account.accountType == .privateKey)
                            state.set(blockchain.ux.asset.account[account.id].is.rewards, to: account.accountType == .interest)
                        }
                    }
                }
                if accounts.contains(where: { $0.accountType == .interest }) {
                    return .merge(update, Effect(value: .fetchInterestRate))
                } else {
                    return update
                }
            case .failure:
                state.error = .failedToLoad
                return .none
            }

        case .reset:
            return .fireAndForget {
                environment.explainerService.resetAll()
            }

        case .observation(.event(let ref, context: let cxt)):
            guard let account = cxt[blockchain.ux.asset.account] as? Account.Snapshot else {
                return .none
            }
            switch ref.tag {
            case blockchain.ux.asset.account.sheet:
                if environment.explainerService.isAccepted(account) {
                    state.account = account
                } else {
                    return .fireAndForget {
                        environment.app.post(
                            event: blockchain.ux.asset.account.explainer[].ref(to: ref.context),
                            context: cxt
                        )
                    }
                }
            case blockchain.ux.asset.account.explainer:
                state.explainer = account
                return .none
            case blockchain.ux.asset.account.explainer.accept:
                state.explainer = nil
                return .fireAndForget {
                    environment.explainerService.accept(account)
                    environment.app.post(
                        event: blockchain.ux.asset.account.sheet[].ref(to: ref.context),
                        context: cxt
                    )
                }
            default:
                break
            }
            return .none
        case .dismiss:
            return .merge(
                .fireAndForget(environment.dismiss),
                .fireAndForget { [state] in
                    environment.app.post(
                        event: blockchain.ux.asset[state.currency.code].article.plain.navigation.bar.button.close
                    )
                }
            )
        case .graph, .binding, .observation:
            return .none
        }
    }
)
.on(blockchain.ux.asset.account.sheet)
.on(blockchain.ux.asset.account.explainer, blockchain.ux.asset.account.explainer.accept)
.binding()
