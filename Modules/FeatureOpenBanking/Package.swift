// swift-tools-version:5.3

import Foundation
import PackageDescription

let package = Package(
    name: "FeatureOpenBanking",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
        .watchOS(.v7),
        .tvOS(.v14)
    ],
    products: [
        .library(
            name: "FeatureOpenBanking",
            targets: ["FeatureOpenBankingData", "FeatureOpenBankingDomain", "FeatureOpenBankingUI"]
        ),
        .library(
            name: "FeatureOpenBankingData",
            targets: ["FeatureOpenBankingData"]
        ),
        .library(
            name: "FeatureOpenBankingDomain",
            targets: ["FeatureOpenBankingDomain"]
        ),
        .library(
            name: "FeatureOpenBankingUI",
            targets: ["FeatureOpenBankingUI"]
        )
    ],
    dependencies: [
        .package(
            name: "combine-schedulers",
            url: "https://github.com/pointfreeco/combine-schedulers",
            from: "0.5.0"
        ),
        .package(
            name: "swift-composable-architecture",
            url: "https://github.com/pointfreeco/swift-composable-architecture",
            .exact("0.38.3")
        ),
        .package(
            name: "swift-case-paths",
            url: "https://github.com/pointfreeco/swift-case-paths",
            from: "0.8.0"
        ),
        .package(path: "../Analytics"),
        .package(path: "../ComposableArchitectureExtensions"),
        .package(path: "../BlockchainComponentLibrary"),
        .package(path: "../BlockchainNamespace"),
        .package(path: "../Errors"),
        .package(path: "../Network"),
        .package(path: "../Test"),
        .package(path: "../Tool"),
        .package(path: "../UIComponents")
    ],
    targets: [
        .target(
            name: "FeatureOpenBankingDomain",
            dependencies: [
                .product(name: "CombineSchedulers", package: "combine-schedulers"),
                .product(name: "CasePaths", package: "swift-case-paths"),
                .product(name: "ToolKit", package: "Tool"),
                .product(name: "BlockchainNamespace", package: "BlockchainNamespace"),
                .product(name: "Errors", package: "Errors")
            ]
        ),
        .target(
            name: "FeatureOpenBankingData",
            dependencies: [
                .target(name: "FeatureOpenBankingDomain"),
                .product(name: "CombineSchedulers", package: "combine-schedulers"),
                .product(name: "NetworkKit", package: "Network"),
                .product(name: "ToolKit", package: "Tool"),
                .product(name: "BlockchainNamespace", package: "BlockchainNamespace")
            ]
        ),
        .target(
            name: "FeatureOpenBankingUI",
            dependencies: [
                .target(name: "FeatureOpenBankingDomain"),
                .target(name: "FeatureOpenBankingData"),
                .product(name: "AnalyticsKit", package: "Analytics"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "ComposableNavigation", package: "ComposableArchitectureExtensions"),
                .product(name: "BlockchainComponentLibrary", package: "BlockchainComponentLibrary"),
                .product(name: "UIComponents", package: "UIComponents"),
                .product(name: "ErrorsUI", package: "Errors")
            ]
        ),
        .target(
            name: "FeatureOpenBankingTestFixture",
            dependencies: [
                .target(name: "FeatureOpenBankingData"),
                .target(name: "FeatureOpenBankingDomain"),
                .product(name: "CombineSchedulers", package: "combine-schedulers"),
                .product(name: "TestKit", package: "Test")
            ],
            resources: [
                // swiftlint:disable line_length
                // $ cd Sources/OpenBankingTestFixture
                // $ fd --glob *.json | xargs -L 1 bash -c 'printf ".copy(\"%s\"),\n" "$*" ' bash
                .copy("fixture/DELETE/nabu-gateway/payments/banktransfer/a44d7d14-15f0-4ceb-bf32-bdcb6c6b393c/DELETE_nabu-gateway_payments_banktransfer_a44d7d14-15f0-4ceb-bf32-bdcb6c6b393c.json"),
                .copy("fixture/GET/nabu-gateway/payments/banktransfer/5adf0e04-ffc5-42ce-bc5b-3ce465016292/GET_nabu-gateway_payments_banktransfer_5adf0e04-ffc5-42ce-bc5b-3ce465016292.json"),
                .copy("fixture/GET/nabu-gateway/payments/banktransfer/GET_nabu-gateway_payments_banktransfer.json"),
                .copy("fixture/GET/nabu-gateway/payments/banktransfer/a44d7d14-15f0-4ceb-bf32-bdcb6c6b393c/GET_nabu-gateway_payments_banktransfer_a44d7d14-15f0-4ceb-bf32-bdcb6c6b393c.json"),
                .copy("fixture/GET/nabu-gateway/payments/payment/b039317d-df85-413f-932d-2719346a839a/GET_nabu-gateway_payments_payment_b039317d-df85-413f-932d-2719346a839a.json"),
                .copy("fixture/GET/nabu-gateway/payments/payment/b039317d-df85-413f-932d-2719346a839a/GET_nabu-gateway_payments_payment_b039317d-df85-413f-932d-2719346a839a_pending.json"),
                .copy("fixture/POST/nabu-gateway/payments/banktransfer/POST_nabu-gateway_payments_banktransfer.json"),
                .copy("fixture/POST/nabu-gateway/payments/banktransfer/a44d7d14-15f0-4ceb-bf32-bdcb6c6b393c/payment/POST_nabu-gateway_payments_banktransfer_a44d7d14-15f0-4ceb-bf32-bdcb6c6b393c_payment.json"),
                .copy("fixture/POST/nabu-gateway/payments/banktransfer/a44d7d14-15f0-4ceb-bf32-bdcb6c6b393c/update/POST_nabu-gateway_payments_banktransfer_a44d7d14-15f0-4ceb-bf32-bdcb6c6b393c_update.json"),
                .copy("fixture/POST/nabu-gateway/payments/banktransfer/one-time-token/POST_nabu-gateway_payments_banktransfer_one-time-token.json")
            ]
        ),
        .testTarget(
            name: "FeatureOpenBankingDataTests",
            dependencies: [
                .target(name: "FeatureOpenBankingData"),
                .target(name: "FeatureOpenBankingTestFixture"),
                .product(name: "CombineSchedulers", package: "combine-schedulers"),
                .product(name: "TestKit", package: "Test")
            ]
        ),
        .testTarget(
            name: "FeatureOpenBankingDomainTests",
            dependencies: [
                .target(name: "FeatureOpenBankingData"),
                .target(name: "FeatureOpenBankingDomain"),
                .target(name: "FeatureOpenBankingTestFixture"),
                .product(name: "CombineSchedulers", package: "combine-schedulers"),
                .product(name: "TestKit", package: "Test")
            ]
        ),
        .testTarget(
            name: "FeatureOpenBankingUITests",
            dependencies: [
                .target(name: "FeatureOpenBankingUI"),
                .target(name: "FeatureOpenBankingTestFixture"),
                .product(name: "CombineSchedulers", package: "combine-schedulers"),
                .product(name: "TestKit", package: "Test")
            ]
        )
    ]
)
