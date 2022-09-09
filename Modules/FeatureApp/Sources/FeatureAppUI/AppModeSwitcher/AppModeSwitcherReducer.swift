import AnalyticsKit
import BlockchainNamespace
import ComposableArchitecture
import ToolKit

public enum AppModeSwitcherModule {}

extension AppModeSwitcherModule {
    public static var reducer: Reducer<AppModeSwitcherState, AppModeSwitcherAction, AppModeSwitcherEnvironment> {
        .init { state, action, environment in
            switch action {
            case .onInit:
                return .merge(
                    environment
                        .recoveryPhraseStatusProviding
                        .isRecoveryPhraseVerifiedPublisher
                        .combineLatest(environment.app.publisher(for: blockchain.user.skipped.seed_phrase.backup, as: Bool.self)
                            .replaceError(with: false)
                        )
                        .receive(on: DispatchQueue.main)
                        .eraseToEffect()
                        .map(AppModeSwitcherAction.onRecoveryPhraseStatusFetched)
                )

            case .onRecoveryPhraseStatusFetched(let isBackedUp, let isSkipped):
                state.recoveryPhraseBackedUp = isBackedUp
                state.recoveryPhraseSkipped = isSkipped
                return .none

            case .onDefiTapped:
                if let defiAccountBalance = state.defiAccountBalance,
                   defiAccountBalance.amount.isZero, state.shouldShowDefiModeIntro
                {
                    state.defiWalletState.isDefiIntroPresented = true
                    return .none
                }

                return .merge(
                    .fireAndForget {
                        environment.app.state.set(blockchain.app.mode, to: AppMode.defi.rawValue)
                    },
                    Effect(value: .dismiss)
                )

            case .onBrokerageTapped:
                return .merge(
                    .fireAndForget {
                        environment.app.state.set(blockchain.app.mode, to: AppMode.trading.rawValue)
                    },
                    Effect(value: .dismiss)
                )

            case .defiWalletIntro(let action):
                switch action {
                case .onBackupSeedPhraseSkip:
                    state.recoveryPhraseSkipped = true
                    return .merge(
                        .fireAndForget {
                            environment.app.state.set(blockchain.user.skipped.seed_phrase.backup, to: true)
                        },
                        Effect(value: .dismiss)
                    )

                case .onBackupSeedPhraseComplete:
                    state.recoveryPhraseBackedUp = true
                    return Effect(value: .onDefiTapped)

                case .onEnableDefiTap:
                    return .merge(
                        .fireAndForget {
                            environment
                                .backupFundsRouter
                                .start()
                        },
                        environment
                            .backupFundsRouter
                            .skipSubject
                            .eraseToEffect()
                            .map { _ in
                                AppModeSwitcherAction.defiWalletIntro(DefiWalletIntroAction.onBackupSeedPhraseSkip)
                            },

                        environment
                            .backupFundsRouter
                            .completionSubject
                            .eraseToEffect()
                            .map { _ in
                                AppModeSwitcherAction.defiWalletIntro(DefiWalletIntroAction.onBackupSeedPhraseComplete)
                            }
                    )
                }

            case .dismiss:
                return .none

            case .binding:
                return .none
            }
        }
        .binding()
        .analytics()
    }
}

extension Reducer where
    Action == AppModeSwitcherAction,
    State == AppModeSwitcherState,
    Environment == AppModeSwitcherEnvironment
{
    /// Helper reducer for analytics tracking
    fileprivate func analytics() -> Self {
        combined(
            with: Reducer<
                AppModeSwitcherState,
                AppModeSwitcherAction,
                AppModeSwitcherEnvironment
            > { _, action, environment in
                switch action {
                case .onBrokerageTapped:
                    environment.analyticsRecorder.record(
                        event: AnalyticsEvents.New.AppModeSwitcher.switchedToTrading
                    )
                    return .none
                case .onDefiTapped:
                    environment.analyticsRecorder.record(
                        event: AnalyticsEvents.New.AppModeSwitcher.switchedToDefi
                    )
                    return .none
                default:
                    return .none
                }
            }
        )
    }
}
