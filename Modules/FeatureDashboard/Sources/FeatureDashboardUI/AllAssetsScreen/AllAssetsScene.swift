import BlockchainNamespace
import ComposableArchitecture
import FeatureDashboardDomain
import Foundation
import MoneyKit
import PlatformKit
import SwiftExtensions

public struct AllAssetsScene: ReducerProtocol {
    public let allCrpyotService: AllCryptoAssetsServiceAPI
    public let app: AppProtocol
    public init(
        allCryptoService: AllCryptoAssetsServiceAPI,
        app: AppProtocol
    ) {
        self.allCrpyotService = allCryptoService
        self.app = app
    }

    public enum Action: Equatable, BindableAction {
        case onAppear
        case onBalancesFetched(TaskResult<[AssetBalanceInfo]>)
        case binding(BindingAction<State>)
        case onFilterTapped
        case onConfirmFilterTapped
        case onResetTapped
        case onAssetTapped(AssetBalanceInfo)
        case onCloseTapped
    }

    public struct State: Equatable {
        var presentedAssetType: PresentedAssetType
        var balanceInfo: [AssetBalanceInfo]?
        @BindableState var searchText: String = ""
        @BindableState var isSearching: Bool = false
        @BindableState var filterPresented: Bool = false
        @BindableState var showSmallBalancesFilterIsOn: Bool = false

        var searchResults: [AssetBalanceInfo]? {
            guard let balanceInfo else {
                return nil
            }
            if searchText.isEmpty {
                        return balanceInfo
                        .filtered(by: showSmallBalancesFilterIsOn)
                   } else
            {
                       return balanceInfo
                           .filtered(by: searchText)
                           .filtered(by: showSmallBalancesFilterIsOn)
            }
        }

        public init(with presentedAssetType: PresentedAssetType) {
            self.presentedAssetType = presentedAssetType
        }
    }

    public var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .task { [assetType = state.presentedAssetType] in
                    await .onBalancesFetched(
                        TaskResult {
                            assetType == .custodial ?
                            await self.allCrpyotService.getAllCryptoAssetsInfo() :
                            await self.allCrpyotService.getAllNonCustodialAssets()
                        }
                    )
                }

            case .binding(\.$searchText):
                return .none

            case .binding(\.$isSearching):
                return .none

            case .onFilterTapped:
                state.filterPresented = true
                return .none

            case .onBalancesFetched(.success(let balanceinfo)):
                state.balanceInfo = balanceinfo.filter(\.cryptoBalance.hasPositiveDisplayableBalance)
              return .none

            case .onBalancesFetched(.failure):
              return .none

            case .onAssetTapped(let assetInfo):
                return .fireAndForget {
                    app.post(
                        action: blockchain.ux.asset.select.then.enter.into,
                        value: blockchain.ux.asset[assetInfo.currency.code],
                        context: [blockchain.ux.asset.select.origin: "ASSETS"]
                    )
                }

            case .onConfirmFilterTapped:
                state.filterPresented = false
                return .none

            case .onResetTapped:
                state.showSmallBalancesFilterIsOn = false
                return .none

            case .binding:
                return .none

            case .onCloseTapped:
                return .none
            }
        }
    }
}

extension [AssetBalanceInfo] {
    func filtered(by searchText: String, using algorithm: StringDistanceAlgorithm = FuzzyAlgorithm(caseInsensitive: true)) -> [Element] {
        filter {
            $0.currency.name.distance(between: searchText, using: algorithm) == 0 ||
            ($0.fiatBalance?.quote.displayString.distance(between: searchText, using: algorithm) ?? 0 < 0.3) ||
            $0.currency.code.distance(between: searchText, using: algorithm) == 0
        }
    }

    func filtered(by smallBalancesFilterIsOn: Bool) -> [Element] {
        filter {
                guard smallBalancesFilterIsOn == false
                else {
                    return true
              }
                return $0.hasBalance
        }
    }
}
