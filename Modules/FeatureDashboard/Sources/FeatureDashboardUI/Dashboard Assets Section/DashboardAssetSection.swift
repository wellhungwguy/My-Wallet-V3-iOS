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

public struct DashboardAssetsSection: ReducerProtocol {
    public let allCryptoAssetService: AllCryptoAssetsServiceAPI
    public let app: AppProtocol
    public init(
        allCryptoAssetService: AllCryptoAssetsServiceAPI,
        app: AppProtocol
    ) {
        self.allCryptoAssetService = allCryptoAssetService
        self.app = app
    }

    public enum Action: Equatable {
        case onAppear
        case onBalancesFetched(TaskResult<[AssetBalanceInfo]>)
        case onFiatBalanceFetched(TaskResult<AssetBalanceInfo?>)
        case onAllAssetsTapped
        case assetRowTapped(
            id: DashboardAssetRow.State.ID,
            action: DashboardAssetRow.Action
        )
    }

    public struct State: Equatable {
        var isLoading: Bool = false
        var fiatAssetInfo: AssetBalanceInfo?
        let presentedAssetsType: PresentedAssetType
        var assetRows: IdentifiedArrayOf<DashboardAssetRow.State> = []
        var seeAllButtonHidden = true
        public init(presentedAssetsType: PresentedAssetType) {
            self.presentedAssetsType = presentedAssetsType
        }
    }

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true
                return .merge(
                    .task { [presentedAssetType = state.presentedAssetsType] in
                        await .onBalancesFetched(
                            TaskResult {
                                presentedAssetType == .custodial ?
                                await self.allCryptoAssetService.getAllCryptoAssetsInfo() :
                                await self.allCryptoAssetService.getAllNonCustodialAssets()
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
                state.isLoading = false
                state.seeAllButtonHidden = balanceInfo
                    .filter(\.cryptoBalance.hasPositiveDisplayableBalance)
                    .count <= state.presentedAssetsType.assetDisplayLimit

                if state.presentedAssetsType == .custodial {
                    state.assetRows = IdentifiedArrayOf(uniqueElements: Array(balanceInfo.filter(\.hasBalance)
                        .prefix(state.presentedAssetsType.assetDisplayLimit))
                        .map {
                            DashboardAssetRow.State(
                                type: state.presentedAssetsType,
                                isLastRow: $0.id == balanceInfo.last?.id,
                                asset: $0
                            )
                        }
                    )
                } else {
                    state.assetRows = IdentifiedArrayOf(uniqueElements: Array(balanceInfo
                        .prefix(state.presentedAssetsType.assetDisplayLimit))
                        .map {
                            DashboardAssetRow.State(
                                type: state.presentedAssetsType,
                                isLastRow: $0.id == balanceInfo.last?.id,
                                asset: $0
                            )
                        }
                    )
                }

                return .none

            case .onBalancesFetched(.failure):
                state.isLoading = false
                return .none

            case .onFiatBalanceFetched(.success(let fiatBalance)):
                state.fiatAssetInfo = fiatBalance
                return .none

            case .onFiatBalanceFetched(.failure):
                return .none

            case .assetRowTapped:
                return .none

            case .onAllAssetsTapped:
                return .none
            }
        }
        .forEach(\.assetRows, action: /Action.assetRowTapped) {
            DashboardAssetRow(app: self.app)
        }
    }
}
