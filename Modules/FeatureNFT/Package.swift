// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "FeatureNFT",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "FeatureNFT",
            targets: [
                "FeatureNFTDomain",
                "FeatureNFTUI",
                "FeatureNFTData"
            ]
        ),
        .library(
            name: "FeatureNFTUI",
            targets: ["FeatureNFTUI"]
        ),
        .library(
            name: "FeatureNFTDomain",
            targets: ["FeatureNFTDomain"]
        )
    ],
    dependencies: [
        .package(
            name: "swift-composable-architecture",
            url: "https://github.com/pointfreeco/swift-composable-architecture",
            from: "0.32.0"
        ),
        .package(
            name: "Nuke",
            url: "https://github.com/kean/Nuke.git",
            from: "10.3.1"
        ),
        .package(path: "../Localization"),
        .package(path: "../UIComponents"),
        .package(path: "../Network"),
        .package(path: "../Errors"),
        .package(path: "../BlockchainComponentLibrary"),
        .package(path: "../ComposableArchitectureExtensions"),
        .package(path: "../CryptoAssets"),
        .package(path: "../Tool")
    ],
    targets: [
        .target(
            name: "FeatureNFTDomain",
            dependencies: [
                .product(
                    name: "Errors",
                    package: "Errors"
                ),
                .product(
                    name: "ToolKit",
                    package: "Tool"
                )
            ]
        ),
        .target(
            name: "FeatureNFTData",
            dependencies: [
                .target(name: "FeatureNFTDomain"),
                .product(
                    name: "NetworkKit",
                    package: "Network"
                ),
                .product(
                    name: "Errors",
                    package: "Errors"
                )
            ]
        ),
        .target(
            name: "FeatureNFTUI",
            dependencies: [
                .target(name: "FeatureNFTDomain"),
                .target(name: "FeatureNFTData"),
                .product(name: "Nuke", package: "Nuke"),
                .product(name: "ComposableNavigation", package: "ComposableArchitectureExtensions"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "Localization", package: "Localization"),
                .product(name: "BlockchainComponentLibrary", package: "BlockchainComponentLibrary"),
                .product(name: "UIComponents", package: "UIComponents"),
                .product(name: "ToolKit", package: "Tool")
            ]
        ),
        .testTarget(
            name: "FeatureNFTDataTests",
            dependencies: [
                .target(name: "FeatureNFTData")
            ]
        ),
        .testTarget(
            name: "FeatureNFTDomainTests",
            dependencies: [
                .target(name: "FeatureNFTDomain")
            ]
        ),
        .testTarget(
            name: "FeatureNFTUITests",
            dependencies: [
                .target(name: "FeatureNFTUI")
            ]
        )
    ]
)
