// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import ComposableArchitecture
import PlatformKit

private typealias Events = AnalyticsEvents.New.KYC

struct UnlockTradingState: Equatable {

    enum UpgradePath: Hashable {
        case basic, verified
    }

    let currentUserTier: KYC.Tier
    @BindableState var selectedUpgradePath: UpgradePath = .verified
}

enum UnlockTradingAction: Equatable, BindableAction {
    case binding(BindingAction<UnlockTradingState>)
    case closeButtonTapped
    case unlockButtonTapped(KYC.Tier)
}

struct UnlockTradingEnvironment {
    let dismiss: () -> Void
    let unlock: (KYC.Tier) -> Void
    let analyticsRecorder: AnalyticsEventRecorderAPI
}

let unlockTradingReducer = Reducer<
    UnlockTradingState,
    UnlockTradingAction,
    UnlockTradingEnvironment
> { _, action, environment in
    switch action {
    case .closeButtonTapped:
        return .fireAndForget {
            environment.dismiss()
        }

    case .unlockButtonTapped(let requiredTier):
        return .fireAndForget {
            environment.unlock(requiredTier)
        }

    case .binding:
        return .none
    }
}
.analytics()
.binding()

// MARK: - Analytics

extension Reducer where State == UnlockTradingState, Action == UnlockTradingAction, Environment == UnlockTradingEnvironment {

    func analytics() -> Self {
        combined(
            with: Reducer { state, action, environment in
                switch action {
                case .binding:
                    return .none

                case .closeButtonTapped:
                    return .none

                case .unlockButtonTapped(let requiredTier):
                    let userTier = state.currentUserTier
                    return .fireAndForget {
                        if requiredTier == .tier1 {
                            environment.analyticsRecorder.record(
                                event: Events.tradingLimitsGetBasicCTAClicked(
                                    tier: userTier.rawValue
                                )
                            )
                        } else {
                            environment.analyticsRecorder.record(
                                event: Events.tradingLimitsGetVerifiedCTAClicked(
                                    tier: userTier.rawValue
                                )
                            )
                        }
                    }
                }
            }
        )
    }
}

// MARK: - SwiftUI Preview Helpers

extension UnlockTradingEnvironment {

    static let preview = UnlockTradingEnvironment(
        dismiss: {},
        unlock: { _ in },
        analyticsRecorder: NoOpAnalyticsRecorder()
    )
}
