// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import ComposableArchitecture
import FeatureDashboardDomain
import Foundation
import SwiftUI

public enum PresentedAssetType {
    case custodial
    case nonCustodial
}

public struct DashboardAssetRow: ReducerProtocol {
    public let app: AppProtocol
    public init(
        app: AppProtocol
    ) {
        self.app = app
    }

    public enum Action: Equatable {
        case onAssetTapped
    }

    public struct State: Equatable, Identifiable {
        public var id: String {
            asset.id
        }

        var type: PresentedAssetType
        var asset: AssetBalanceInfo
        var isLastRow: Bool

        var trailingDescriptionString: String {
            switch type {
            case .custodial:
                return asset.priceChangeString ?? ""
            case .nonCustodial:
                return asset.cryptoBalance.toDisplayString(includeSymbol: true)
            }
        }

        var trailingDescriptionColor: Color? {
            type == .custodial ? asset.priceChangeColor : nil
        }

        public init(
            type: PresentedAssetType,
            isLastRow: Bool,
            asset: AssetBalanceInfo
        ) {
            self.type = type
            self.asset = asset
            self.isLastRow = isLastRow
        }
    }

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAssetTapped:
                print(state.asset)
                return .fireAndForget { [assetInfo = state.asset] in
                    print(assetInfo)
                    self.app.post(
                        event: blockchain.ux.asset[assetInfo.currency.code].select,
                        context: [blockchain.ux.asset.select.origin: "ASSETS"]
                    )
                }
            }
        }
    }
}
