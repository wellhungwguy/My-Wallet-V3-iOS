// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// A list of supported assets.
struct SupportedAssets {

    // MARK: - Internal Properties

    /// The empty list of supported assets.
    static let empty = SupportedAssets(currencies: [])

    /// The list of supported assets.
    let currencies: [AssetModel]

    // MARK: - Setup

    /// Creates a list of supported assets.
    ///
    /// - Parameter response: A supported assets response.
    init(response: SupportedAssetsResponse, sanitizePolygonAssets: Bool) {
        currencies = response.currencies
            .enumerated()
            .compactMap { index, item -> AssetModel? in
                // TODO: IOS-5091: remove sortIndex, cryptocurrencies should not have an order,
                // but accounts should be sorted by balance.
                AssetModel(assetResponse: item, sortIndex: index, sanitizePolygonAssets: sanitizePolygonAssets)
            }
    }

    /// Creates a list of supported assets.
    ///
    /// - Parameter currencies: A list of supported assets.
    private init(currencies: [AssetModel]) {
        self.currencies = currencies
    }
}
