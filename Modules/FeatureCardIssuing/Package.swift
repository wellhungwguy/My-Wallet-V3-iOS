// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "FeatureCardIssuing",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
        .watchOS(.v7),
        .tvOS(.v14)
    ],
    products: [
        .library(
            name: "FeatureCardIssuing",
            targets: ["FeatureCardIssuingData", "FeatureCardIssuingDomain", "FeatureCardIssuingUI"]
        ),
        .library(
            name: "FeatureCardIssuingUI",
            targets: ["FeatureCardIssuingUI"]
        ),
        .library(
            name: "FeatureCardIssuingDomain",
            targets: ["FeatureCardIssuingDomain"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/dchatzieleftheriou-bc/DIKit.git",
            branch: "safe-property-wrappers-locks"
        ),
        .package(
            url: "https://github.com/pointfreeco/swift-composable-architecture",
            exact: "0.39.1"
        ),
        .package(path: "../Analytics"),
        .package(path: "../ComposableArchitectureExtensions"),
        .package(path: "../Localization"),
        .package(path: "../Network"),
        .package(path: "../Errors"),
        .package(path: "../Extensions"),
        .package(path: "../Tool"),
        .package(path: "../Money"),
        .package(path: "../BlockchainComponentLibrary")
    ],
    targets: [
        .target(
            name: "FeatureCardIssuingDomain",
            dependencies: [
                .product(name: "Errors", package: "Errors"),
                .product(name: "NetworkKit", package: "Network"),
                .product(name: "ToolKit", package: "Tool"),
                .product(name: "MoneyKit", package: "Money")
            ]
        ),
        .target(
            name: "FeatureCardIssuingData",
            dependencies: [
                .target(name: "FeatureCardIssuingDomain"),
                .product(name: "DIKit", package: "DIKit"),
                .product(name: "NetworkKit", package: "Network"),
                .product(name: "Errors", package: "Errors"),
                .product(name: "ToolKit", package: "Tool"),
                .product(name: "MoneyKit", package: "Money")
            ]
        ),
        .target(
            name: "FeatureCardIssuingUI",
            dependencies: [
                .target(name: "FeatureCardIssuingDomain"),
                .product(name: "AnalyticsKit", package: "Analytics"),
                .product(name: "BlockchainComponentLibrary", package: "BlockchainComponentLibrary"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "Errors", package: "Errors"),
                .product(name: "Localization", package: "Localization"),
                .product(name: "MoneyKit", package: "Money"),
                .product(name: "ToolKit", package: "Tool"),
                .product(name: "ComposableArchitectureExtensions", package: "ComposableArchitectureExtensions"),
                .product(name: "Extensions", package: "Extensions")
            ]
        )
    ]
)
