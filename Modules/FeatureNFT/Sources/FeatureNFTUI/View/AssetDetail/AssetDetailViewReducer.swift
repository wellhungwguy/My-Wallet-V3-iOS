import Combine
import ComposableArchitecture
import FeatureNFTDomain

struct AssetDetailEnvironment {}

let assetDetailReducer = Reducer<
    AssetDetailViewState,
    AssetDetailViewAction,
    AssetDetailEnvironment
> { _, action, _ in
    switch action {
    case .viewOnWebTapped:
        return .none
    }
}
