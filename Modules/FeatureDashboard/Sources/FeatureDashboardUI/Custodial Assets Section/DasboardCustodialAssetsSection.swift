// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import ComposableArchitecture
import ComposableArchitectureExtensions
import DIKit
import FeatureDashboardDomain
import Foundation
import MoneyKit
import PlatformKit
import SwiftUI

public struct DashboardCustodialAssetsSection: ReducerProtocol {
    public let allCryptoAssetsRepository: AllCryptoAssetsRepositoryAPI
    public let allCryptoAssetService: AllCryptoAssetsServiceAPI

    public let app: AppProtocol
    public init(
        allCryptoAssetsRepository: AllCryptoAssetsRepositoryAPI,
        allCryptoAssetService: AllCryptoAssetsServiceAPI,
        app: AppProtocol
    ) {
        self.allCryptoAssetsRepository = allCryptoAssetsRepository
        self.allCryptoAssetService = allCryptoAssetService
        self.app = app
    }

    public enum Action: Equatable {
        case onAppear
        case onBalancesFetched(TaskResult<[AssetBalanceInfo]>)
        case onFiatBalanceFetched(TaskResult<AssetBalanceInfo?>)
        case onAllAssetsTapped
        case onAssetTapped(AssetBalanceInfo)
    }

    public struct State: Equatable {
        var custodialAssetsInfo: [AssetBalanceInfo]?
        var fiatAssetInfo: AssetBalanceInfo?
        public init() {}
    }

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .merge(
                    .task {
                        await .onBalancesFetched(
                            TaskResult {
                                try await self.allCryptoAssetsRepository.assetsInfo.await()
                            }
                        )
                    },
                    .task {
                        await .onFiatBalanceFetched(
                            TaskResult {
                                await self.allCryptoAssetService.getFiatAssetsInfo()
                            }
                        )
                    }
                )
            case .onBalancesFetched(.success(let balanceInfo)):
                state.custodialAssetsInfo = Array(balanceInfo.filter(\.cryptoBalance.hasPositiveDisplayableBalance).prefix(8))
                return .none

            case .onBalancesFetched(.failure):
                return .none

            case .onFiatBalanceFetched(.success(let fiatBalance)):
                state.fiatAssetInfo = fiatBalance
                return .none

            case .onFiatBalanceFetched(.failure):
                return .none

            case .onAssetTapped(let assetInfo):
                return .fireAndForget {
                    self.app.post(
                        event: blockchain.ux.asset[assetInfo.currency.code].select,
                        context: [blockchain.ux.asset.select.origin: "ASSETS"]
                    )
                }

            case .onAllAssetsTapped:
                return .none
            }
        }
    }
}
