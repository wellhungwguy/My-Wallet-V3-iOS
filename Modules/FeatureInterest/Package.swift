// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "FeatureInterest",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
        .watchOS(.v7),
        .tvOS(.v14)
    ],
    products: [
        .library(
            name: "FeatureInterest",
            targets: ["FeatureInterestData", "FeatureInterestDomain", "FeatureInterestUI"]
        ),
        .library(name: "FeatureInterestData", targets: ["FeatureInterestData"]),
        .library(name: "FeatureInterestDomain", targets: ["FeatureInterestDomain"]),
        .library(name: "FeatureInterestUI", targets: ["FeatureInterestUI"])
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
        .package(
            url: "https://github.com/ReactiveX/RxSwift.git",
            from: "6.5.0"
        ),
        .package(path: "../Localization"),
        .package(path: "../FeatureTransaction"),
        .package(path: "../Network"),
        .package(path: "../Errors"),
        .package(path: "../UIComponents"),
        .package(path: "../ComposableArchitectureExtensions"),
        .package(path: "../Platform"),
        .package(path: "../Tool"),
        .package(path: "../Analytics")
    ],
    targets: [
        .target(
            name: "FeatureInterestDomain",
            dependencies: [
                .product(name: "FeatureTransactionDomain", package: "FeatureTransaction"),
                .product(name: "PlatformKit", package: "Platform"),
                .product(name: "RxSwift", package: "RxSwift"),
                .product(name: "Errors", package: "Errors"),
                .product(name: "NetworkKit", package: "Network")
            ]
        ),
        .target(
            name: "FeatureInterestData",
            dependencies: [
                .target(name: "FeatureInterestDomain"),
                .product(name: "DIKit", package: "DIKit"),
                .product(name: "Errors", package: "Errors"),
                .product(name: "NetworkKit", package: "Network")
            ]
        ),
        .target(
            name: "FeatureInterestUI",
            dependencies: [
                .target(name: "FeatureInterestDomain"),
                .product(name: "DIKit", package: "DIKit"),
                .product(name: "ComposableNavigation", package: "ComposableArchitectureExtensions"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "FeatureTransactionUI", package: "FeatureTransaction"),
                .product(name: "Localization", package: "Localization"),
                .product(name: "PlatformUIKit", package: "Platform"),
                .product(name: "UIComponents", package: "UIComponents"),
                .product(name: "ToolKit", package: "Tool"),
                .product(name: "AnalyticsKit", package: "Analytics")
            ]
        ),
        .testTarget(
            name: "FeatureInterestDataTests",
            dependencies: [
                .target(name: "FeatureInterestData")
            ]
        ),
        .testTarget(
            name: "FeatureInterestDomainTests",
            dependencies: [
                .target(name: "FeatureInterestDomain")
            ]
        ),
        .testTarget(
            name: "FeatureInterestUITests",
            dependencies: [
                .target(name: "FeatureInterestUI")
            ]
        )
    ]
)
