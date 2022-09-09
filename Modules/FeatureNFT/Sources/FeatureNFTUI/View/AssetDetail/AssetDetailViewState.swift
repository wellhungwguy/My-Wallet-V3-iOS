// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureNFTDomain

public struct AssetDetailViewState: Equatable {

    let asset: Asset

    public init(asset: Asset) {
        self.asset = asset
    }
}
