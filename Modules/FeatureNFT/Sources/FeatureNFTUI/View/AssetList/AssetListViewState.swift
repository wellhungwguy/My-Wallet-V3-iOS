// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import ComposableNavigation
import FeatureNFTDomain

public struct AssetListViewState: NavigationState, Equatable {

    var next: String?
    var assetDetailViewState: AssetDetailViewState?
    var assets: [Asset] = []
    var isLoading: Bool = false
    var isPaginating: Bool = false
    var error: AssetProviderServiceError?
    public var route: RouteIntent<AssetListRoute>?
}

extension AssetListViewState {

    var isEmpty: Bool {
        !isLoading && assets.isEmpty && error == nil
    }

    var shouldShowList: Bool {
        !isLoading && !isEmpty
    }

    var shouldShowErrorState: Bool {
        error != nil && !isLoading && assets.isEmpty
    }
}

extension AssetListViewState {
    public static let empty: AssetListViewState = .init()
}
