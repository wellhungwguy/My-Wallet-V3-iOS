// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import MoneyDomainKit

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
    init(response: SupportedAssetsResponse, sanitizeEVMAssets: Bool) {
        currencies = response.currencies
            .enumerated()
            .compactMap { index, item -> AssetModel? in
                AssetModel(assetResponse: item, sortIndex: index, sanitizeEVMAssets: sanitizeEVMAssets)
            }
    }

    /// Creates a list of supported assets.
    ///
    /// - Parameter currencies: A list of supported assets.
    private init(currencies: [AssetModel]) {
        self.currencies = currencies
    }
}
