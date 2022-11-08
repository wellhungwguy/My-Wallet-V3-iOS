// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

import BlockchainNamespace
import ComposableArchitecture
import ComposableArchitectureExtensions
import DIKit
import FeatureDashboardDomain
import MoneyKit
import PlatformKit
import SwiftUI

public struct DashboardActivitySection: ReducerProtocol {
    public let app: AppProtocol
    public init(
        app: AppProtocol
    ) {
        self.app = app
    }

    public enum Action: Equatable {
        case onAppear
//        case onActivityTapped
//        case onActivityFetched(TaskResult<>)
        case onAllActivityTapped
    }

    public struct State: Equatable {
//        var activityItems: []?
        public init() {}
    }

    public var body: some ReducerProtocol<State, Action> {
        Reduce { _, action in
            switch action {
            case .onAppear:
                return .none
            case .onAllActivityTapped:
                return .none
                //                return .merge(
                //                    .task {
                //                        await .onActivityFetched(
                //                            TaskResult {
                // Insert call here
                //                            }
                //                        )
                //                    }
                //                )
                //            case .onActivityFetched(.success(let balanceInfo)):
                //                return .none

                //            case .onActivityFetched(.failure):
                //                return .none
            }
        }
    }
}
