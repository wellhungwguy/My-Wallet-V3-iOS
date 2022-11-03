// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import MoneyDomainKit

extension AssetModel {

    /// Creates an AssetModel asset.
    ///
    /// - Parameters:
    ///   - assetResponse: A supported SupportedAssetsResponse.Asset object.
    ///   - sortIndex:     A sorting index.
    init?(assetResponse: SupportedAssetsResponse.Asset, sortIndex: Int, sanitizeEVMAssets: Bool) {
        let code = assetResponse.symbol
        let displayCode = assetResponse.displaySymbol ?? assetResponse.symbol
        let name = Self.name(assetResponse, sanitizeEVMAssets: sanitizeEVMAssets)
        let precision = assetResponse.precision
        let products = assetResponse.products.compactMap(AssetModelProduct.init).unique
        let logoPngUrl = assetResponse.type.logoPngUrl.flatMap(URL.init)
        let spotColor = assetResponse.type.spotColor

        guard let assetModelType = assetResponse.type.assetModelType else {
            return nil
        }
        let kind = assetModelType
        let sortIndex = assetModelType.baseSortIndex + sortIndex
        self.init(
            code: code,
            displayCode: displayCode,
            kind: kind,
            name: name,
            precision: precision,
            products: products,
            logoPngUrl: logoPngUrl,
            spotColor: spotColor,
            sortIndex: sortIndex
        )
    }

    static func name(
        _ response: SupportedAssetsResponse.Asset,
        sanitizeEVMAssets: Bool
    ) -> String {
        let name = response.name
        guard sanitizeEVMAssets else {
            return name
        }
        guard let network = response.type.parentChain.flatMap(AssetModelType.ERC20ParentChain.init) else {
            return name
        }
        guard network != .ethereum else {
            return name
        }
        let evmAssetNameSuffix = " - \(network.name)"
        guard !name.hasSuffix(evmAssetNameSuffix) else {
            return name
        }
        return name + evmAssetNameSuffix
    }
}

extension SupportedAssetsResponse.Asset.AssetType {
    fileprivate var assetModelType: AssetModelType? {
        switch name {
        case Self.Name.fiat.rawValue:
            return .fiat
        case Self.Name.celoToken.rawValue:
            return .celoToken(parentChain: .celo)
        case Self.Name.coin.rawValue:
            return .coin(
                minimumOnChainConfirmations: minimumOnChainConfirmations ?? 0
            )
        case Self.Name.erc20.rawValue:
            guard let erc20Address else {
                return nil
            }
            guard let parentChain = parentChain
                .flatMap(AssetModelType.ERC20ParentChain.init(rawValue:))
            else {
                return nil
            }
            return .erc20(
                contractAddress: erc20Address,
                parentChain: parentChain
            )
        default:
            return nil
        }
    }
}

extension AssetModelType {
    fileprivate var baseSortIndex: Int {
        switch self {
        case .celoToken:
            return 100
        case .coin:
            return 10
        case .erc20:
            return 10000
        case .fiat:
            return 0
        }
    }
}
