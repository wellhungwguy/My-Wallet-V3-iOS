// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import ComposableNavigation
import Errors
import FeatureNFTDomain
import Foundation

public enum AssetListViewAction: Equatable, NavigationAction {
    case onAppear
    case increaseOffset
    case fetchNextPageIfNeeded
    case assetTapped(Asset)
    case copyEthereumAddressTapped
    case copyEthereumAddress(Result<String, AssetProviderServiceError>)
    case assetDetailsViewAction(AssetDetailViewAction)
    case fetchedAssets(Result<NFTAssetPage, AssetProviderServiceError>)
    case route(RouteIntent<AssetListRoute>?)
}
