// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "FeatureAuthentication",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
        .watchOS(.v7),
        .tvOS(.v14)
    ],
    products: [
        .library(
            name: "FeatureAuthentication",
            targets: ["FeatureAuthenticationData", "FeatureAuthenticationDomain", "FeatureAuthenticationUI"]
        ),
        .library(
            name: "FeatureAuthenticationData",
            targets: ["FeatureAuthenticationData"]
        ),
        .library(
            name: "FeatureAuthenticationUI",
            targets: ["FeatureAuthenticationUI"]
        ),
        .library(
            name: "FeatureAuthenticationDomain",
            targets: ["FeatureAuthenticationDomain"]
        ),
        .library(
            name: "FeatureAuthenticationMock",
            targets: ["FeatureAuthenticationMock"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/oliveratkinson-bc/zxcvbn-ios.git",
            branch: "swift-package-manager"
        ),
        .package(
            url: "https://github.com/jackpooleybc/DIKit.git",
            branch: "safe-property-wrappers"
        ),
        .package(
            url: "https://github.com/pointfreeco/swift-composable-architecture",
            from: "0.38.3"
        ),
        .package(path: "../Analytics"),
        .package(path: "../BlockchainNamespace"),
        .package(path: "../ComposableArchitectureExtensions"),
        .package(path: "../HDWallet"),
        .package(path: "../Localization"),
        .package(path: "../Network"),
        .package(path: "../Errors"),
        .package(path: "../Test"),
        .package(path: "../Tool"),
        .package(path: "../UIComponents"),
        .package(path: "../WalletPayload")
    ],
    targets: [
        .target(
            name: "FeatureAuthenticationDomain",
            dependencies: [
                .product(name: "HDWalletKit", package: "HDWallet"),
                .product(name: "NetworkKit", package: "Network"),
                .product(name: "Errors", package: "Errors"),
                .product(name: "ToolKit", package: "Tool"),
                .product(name: "Zxcvbn", package: "zxcvbn-ios"),
                .product(name: "WalletPayloadKit", package: "WalletPayload")
            ]
        ),
        .target(
            name: "FeatureAuthenticationData",
            dependencies: [
                .target(name: "FeatureAuthenticationDomain"),
                .product(name: "DIKit", package: "DIKit"),
                .product(name: "NetworkKit", package: "Network"),
                .product(name: "Errors", package: "Errors"),
                .product(name: "WalletPayloadKit", package: "WalletPayload")
            ]
        ),
        .target(
            name: "FeatureAuthenticationUI",
            dependencies: [
                .target(name: "FeatureAuthenticationDomain"),
                .product(name: "BlockchainNamespace", package: "BlockchainNamespace"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "ComposableNavigation", package: "ComposableArchitectureExtensions"),
                .product(name: "AnalyticsKit", package: "Analytics"),
                .product(name: "Localization", package: "Localization"),
                .product(name: "ToolKit", package: "Tool"),
                .product(name: "UIComponents", package: "UIComponents")
            ]
        ),
        .target(
            name: "FeatureAuthenticationMock",
            dependencies: [
                .target(name: "FeatureAuthenticationData"),
                .target(name: "FeatureAuthenticationDomain"),
                .product(name: "WalletPayloadKit", package: "WalletPayload"),
                .product(name: "WalletPayloadDataKit", package: "WalletPayload"),
                .product(name: "WalletPayloadKitMock", package: "WalletPayload")
            ]
        ),
        .testTarget(
            name: "FeatureAuthenticationDataTests",
            dependencies: [
                .target(name: "FeatureAuthenticationData"),
                .target(name: "FeatureAuthenticationMock"),
                .product(name: "ToolKitMock", package: "Tool"),
                .product(name: "WalletPayloadKit", package: "WalletPayload"),
                .product(name: "WalletPayloadDataKit", package: "WalletPayload"),
                .product(name: "WalletPayloadKitMock", package: "WalletPayload"),
                .product(name: "TestKit", package: "Test")
            ]
        ),
        .testTarget(
            name: "FeatureAuthenticationUITests",
            dependencies: [
                .target(name: "FeatureAuthenticationData"),
                .target(name: "FeatureAuthenticationMock"),
                .target(name: "FeatureAuthenticationUI"),
                .product(name: "AnalyticsKitMock", package: "Analytics"),
                .product(name: "TestKit", package: "Test"),
                .product(name: "ToolKitMock", package: "Tool")
            ]
        )
    ]
)
