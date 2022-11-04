// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "FeatureStaking",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
        .watchOS(.v7),
        .tvOS(.v14)
    ],
    products: [
        .library(
            name: "FeatureStaking",
            targets: ["FeatureStakingData"]
        ),
        .library(name: "FeatureStakingData", targets: ["FeatureStakingData"]),
        .library(name: "FeatureStakingDomain", targets: ["FeatureStakingDomain"]),
        .library(name: "FeatureStakingUI", targets: ["FeatureStakingUI"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/pointfreeco/swift-composable-architecture",
            exact: "0.42.0"
        ),
        .package(
            url: "https://github.com/dchatzieleftheriou-bc/DIKit.git",
            branch: "safe-property-wrappers-locks"
        ),
        .package(path: "../Localization"),
        .package(path: "../Network"),
        .package(path: "../Errors"),
        .package(path: "../Platform"),
        .package(path: "../Tool"),
        .package(path: "../Money"),
        .package(path: "../Analytics")
    ],
    targets: [
        .target(
            name: "FeatureStakingData",
            dependencies: [
                .target(name: "FeatureStakingDomain"),
                .product(name: "DIKit", package: "DIKit"),
                .product(name: "Errors", package: "Errors"),
                .product(name: "NetworkKit", package: "Network")
            ]
        ),
        .target(
            name: "FeatureStakingDomain",
            dependencies: [
                .product(name: "DIKit", package: "DIKit"),
                .product(name: "PlatformKit", package: "Platform"),
                .product(name: "Errors", package: "Errors"),
                .product(name: "NetworkKit", package: "Network"),
                .product(name: "MoneyKit", package: "Money")
            ]
        ),
        .target(
            name: "FeatureStakingUI",
            dependencies: [
                .target(name: "FeatureStakingDomain")
            ]
        ),
        .testTarget(
            name: "FeatureStakingDataTests",
            dependencies: ["FeatureStakingData"]
        ),
        .testTarget(
            name: "FeatureStakingDomainTests",
            dependencies: ["FeatureStakingDomain"]
        ),
        .testTarget(
            name: "FeatureStakingUITests",
            dependencies: ["FeatureStakingUI"]
        )
    ]
)
