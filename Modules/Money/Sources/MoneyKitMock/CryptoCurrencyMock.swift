// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import MoneyKit

extension AssetModel {
    static func mockERC20(
        symbol: String,
        displaySymbol: String,
        name: String,
        erc20Address: String = "ETH",
        precision: Int = 18,
        sortIndex: Int = 0
    ) -> AssetModel {
        AssetModel(
            assetResponse: .init(
                symbol: symbol,
                displaySymbol: displaySymbol,
                name: name,
                precision: precision,
                products: [],
                type: .init(
                    name: "ERC20",
                    minimumOnChainConfirmations: nil,
                    parentChain: "ETH",
                    erc20Address: erc20Address,
                    logoPngUrl: "ETH",
                    spotColor: nil,
                    websiteUrl: "ETH"
                )
            ),
            sortIndex: sortIndex,
            sanitizeEVMAssets: true
        )!
    }

    static func mockCoin(
        symbol: String,
        displaySymbol: String,
        name: String,
        precision: Int = 18,
        sortIndex: Int = 0
    ) -> AssetModel {
        AssetModel(
            assetResponse: .init(
                symbol: symbol,
                displaySymbol: displaySymbol,
                name: name,
                precision: precision,
                products: [],
                type: .init(
                    name: "COIN",
                    minimumOnChainConfirmations: 3,
                    parentChain: nil,
                    erc20Address: nil,
                    logoPngUrl: nil,
                    spotColor: nil,
                    websiteUrl: nil
                )
            ),
            sortIndex: sortIndex,
            sanitizeEVMAssets: true
        )!
    }
}

extension CryptoCurrency {

    static func mockERC20(
        symbol: String = "",
        displaySymbol: String = "",
        name: String = "",
        erc20Address: String = "ETH",
        precision: Int = 18,
        sortIndex: Int = 0
    ) -> CryptoCurrency {
        AssetModel.mockERC20(
            symbol: symbol,
            displaySymbol: displaySymbol,
            name: name,
            erc20Address: erc20Address,
            precision: precision,
            sortIndex: sortIndex
        ).cryptoCurrency!
    }

    static func mockCoin(
        symbol: String = "",
        displaySymbol: String = "",
        name: String = "",
        precision: Int = 18,
        sortIndex: Int = 0
    ) -> CryptoCurrency {
        AssetModel.mockCoin(
            symbol: symbol,
            displaySymbol: displaySymbol,
            name: name,
            precision: precision,
            sortIndex: sortIndex
        ).cryptoCurrency!
    }
}
