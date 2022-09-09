// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import ToolKit

/// An asset (crypto or fiat).
public struct AssetModel: Hashable {

    // MARK: - Public Properties

    /// The asset code (e.g. `USD`, `BTC`, etc.).
    public let code: String
    /// The asset display code (e.g. `USD`, `BTC`, etc.).
    public let displayCode: String
    /// The asset type.
    public let kind: AssetModelType
    /// The asset name (e.g. `US Dollar`, `Bitcoin`, etc.).
    public let name: String
    /// The asset precision, representing the maximum number of fraction digits.
    public let precision: Int
    /// The list of supported asset products.
    public let products: [AssetModelProduct]
    /// The URL to the asset logo.
    public let logoPngUrl: URL?
    /// The asset spot color.
    public let spotColor: String?

    // MARK: - Internal Properties

    /// Temporary sorting index, while full dynamic asset migration is in progress.
    let sortIndex: Int

    // MARK: - Setup

    /// Creates an AssetModel asset.
    ///
    /// - Parameters:
    ///   - assetResponse: A supported SupportedAssetsResponse.Asset object.
    ///   - sortIndex:     A sorting index.
    init?(assetResponse: SupportedAssetsResponse.Asset, sortIndex: Int, sanitizePolygonAssets: Bool) {
        code = assetResponse.symbol
        displayCode = Self.displayCode(assetResponse, sanitizePolygonAssets: sanitizePolygonAssets)
        name = Self.name(assetResponse, sanitizePolygonAssets: sanitizePolygonAssets)
        precision = assetResponse.precision
        var products = assetResponse.products.compactMap(AssetModelProduct.init)
        self.products = products.unique
        logoPngUrl = URL(string: assetResponse.type.logoPngUrl ?? "")
        spotColor = assetResponse.type.spotColor

        guard let assetModelType = assetResponse.type.assetModelType else {
            return nil
        }
        kind = assetModelType
        self.sortIndex = assetModelType.baseSortIndex + sortIndex
    }

    public init(
        code: String,
        displayCode: String,
        kind: AssetModelType,
        name: String,
        precision: Int,
        products: [AssetModelProduct],
        logoPngUrl: URL?,
        spotColor: String?,
        sortIndex: Int
    ) {
        self.code = code
        self.displayCode = displayCode
        self.kind = kind
        self.name = name
        self.precision = precision
        self.products = products
        self.logoPngUrl = logoPngUrl
        self.spotColor = spotColor
        self.sortIndex = sortIndex
    }

    // MARK: - Internal Methods

    /// Creates a new AssetModel asset by replacing the current list of supported asset products.
    ///
    /// - Parameter products: A list of supported asset products.
    func with(products: [AssetModelProduct]) -> AssetModel {
        AssetModel(
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

    public func hash(into hasher: inout Hasher) {
        hasher.combine(code)
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.code == rhs.code
    }

    public func supports(product: AssetModelProduct) -> Bool {
        products.contains(product)
    }

    static func name(
        _ response: SupportedAssetsResponse.Asset,
        sanitizePolygonAssets: Bool
    ) -> String {
        let polygonSuffix = " - Polygon"
        let name = response.name
        guard sanitizePolygonAssets else {
            return name
        }
        guard response.type.parentChain == "MATIC" else {
            return name
        }
        guard !name.hasSuffix(polygonSuffix) else {
            return name
        }
        return name + polygonSuffix
    }

    static func displayCode(
        _ response: SupportedAssetsResponse.Asset,
        sanitizePolygonAssets: Bool
    ) -> String {
        let displaySymbol = response.displaySymbol ?? response.symbol
        guard sanitizePolygonAssets, response.type.parentChain == "MATIC" else {
            return displaySymbol
        }
        return String(displaySymbol.dropSuffix(".MATIC"))
    }
}

extension AssetModel {

    public var cryptoCurrency: CryptoCurrency? {
        CryptoCurrency(assetModel: self)
    }

    // swiftlint:disable line_length

    public static let bitcoin = AssetModel(
        code: "BTC",
        displayCode: "BTC",
        kind: .coin(minimumOnChainConfirmations: 2),
        name: "Bitcoin",
        precision: 8,
        products: AssetModelProduct.allCases,
        logoPngUrl: URL("https://raw.githubusercontent.com/blockchain/coin-definitions/master/extensions/blockchains/bitcoin/info/logo.png"),
        spotColor: "FF9B22",
        sortIndex: 1
    )

    public static let bitcoinCash = AssetModel(
        code: "BCH",
        displayCode: "BCH",
        kind: .coin(minimumOnChainConfirmations: 3),
        name: "Bitcoin Cash",
        precision: 8,
        products: AssetModelProduct.allCases,
        logoPngUrl: URL("https://raw.githubusercontent.com/blockchain/coin-definitions/master/extensions/blockchains/bitcoincash/info/logo.png"),
        spotColor: "8DC351",
        sortIndex: 3
    )

    public static let ethereum = AssetModel(
        code: "ETH",
        displayCode: "ETH",
        kind: .coin(minimumOnChainConfirmations: 30),
        name: "Ethereum",
        precision: 18,
        products: AssetModelProduct.allCases,
        logoPngUrl: URL("https://raw.githubusercontent.com/blockchain/coin-definitions/master/extensions/blockchains/ethereum/info/logo.png"),
        spotColor: "473BCB",
        sortIndex: 2
    )

    public static let stellar = AssetModel(
        code: "XLM",
        displayCode: "XLM",
        kind: .coin(minimumOnChainConfirmations: 3),
        name: "Stellar",
        precision: 7,
        products: AssetModelProduct.allCases,
        logoPngUrl: URL("https://raw.githubusercontent.com/blockchain/coin-definitions/master/extensions/blockchains/stellar/info/logo.png"),
        spotColor: "000000",
        sortIndex: 4
    )

    public static let polygon = AssetModel(
        code: "MATIC.MATIC",
        displayCode: "MATIC",
        kind: .coin(minimumOnChainConfirmations: 128),
        name: "Polygon",
        precision: 18,
        products: [.privateKey],
        logoPngUrl: "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/polygon/info/logo.png",
        spotColor: nil,
        sortIndex: 5
    )
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
            guard let erc20Address = erc20Address else {
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
