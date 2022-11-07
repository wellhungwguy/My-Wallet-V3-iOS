import BlockchainNamespace
import ComposableArchitecture
import FeatureDashboardDomain
import Foundation
import MoneyKit
import PlatformKit
import SwiftExtensions

public struct FeatureAllAssets: ReducerProtocol {
    public let allCryptoAssetsRepository: AllCryptoAssetsRepositoryAPI
    public let app: AppProtocol
    public init(
        allCryptoAssetsRepository: AllCryptoAssetsRepositoryAPI,
        app: AppProtocol
    ) {
        self.allCryptoAssetsRepository = allCryptoAssetsRepository
        self.app = app
    }

    public enum Action: Equatable, BindableAction {
        case onAppear
        case onBalancesFetched(TaskResult<[CryptoAssetInfo]>)
        case binding(BindingAction<State>)
        case onFilterTapped
        case onConfirmFilterTapped
        case onResetTapped
        case onAssetTapped(CryptoAssetInfo)
    }

    public struct State: Equatable {
        var balanceInfo: [CryptoAssetInfo]?
        @BindableState var searchText: String = ""
        @BindableState var isSearching: Bool = false
        @BindableState var filterPresented: Bool = false
        @BindableState var showSmallBalancesFilterIsOn: Bool = false

        var searchResults: [CryptoAssetInfo]? {
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

        public init() {}
    }

    public var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .task {
                    await .onBalancesFetched(
                        TaskResult {
                            try await self.allCryptoAssetsRepository.assetsInfo.await()
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
                    self.app.post(
                        event: blockchain.ux.asset[assetInfo.currency.code].select,
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
            }
        }
    }
}

extension [CryptoAssetInfo] {
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
