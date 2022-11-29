// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

import AsyncAlgorithms
import BlockchainNamespace
import ComposableArchitecture
import ComposableArchitectureExtensions
import DIKit
import FeatureDashboardDomain
import MoneyKit
import PlatformKit
import SwiftUI
import UnifiedActivityDomain

public struct DashboardActivitySection: ReducerProtocol {
    public let app: AppProtocol
    public let activityRepository: UnifiedActivityRepositoryAPI
    public init(
        app: AppProtocol,
        activityRepository: UnifiedActivityRepositoryAPI
    ) {
        self.app = app
        self.activityRepository = activityRepository
    }

    public enum Action: Equatable {
        case onAppear
        case onActivityFetched([ActivityEntry])
        case onAllActivityTapped
        case onActivityRowTapped(
            id: DashboardActivityRow.State.ID,
            action: DashboardActivityRow.Action
        )
    }

    public struct State: Equatable {
        var activityRows: IdentifiedArrayOf<DashboardActivityRow.State> = []

        public init() {}
    }

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return activityRepository
                    .activity
                    .receive(on: DispatchQueue.main)
                    .eraseToEffect { .onActivityFetched($0) }

            case .onAllActivityTapped:
                return .none
            case .onActivityRowTapped:
                return .none
            case .onActivityFetched(let activity):
                state.activityRows = IdentifiedArrayOf(uniqueElements: Array(activity.prefix(5))
                    .map {
                    DashboardActivityRow.State(
                        isLastRow: $0.id == activity.last?.id,
                        activity: $0
                    )
                    })
                return .none
            }
        }
        .forEach(\.activityRows, action: /Action.onActivityRowTapped) {
            DashboardActivityRow(app: self.app)
        }
    }
}
