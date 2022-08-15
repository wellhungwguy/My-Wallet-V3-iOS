// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FeatureWithdrawalLocks",
    defaultLocalization: "en",
    platforms: [.iOS(.v14), .macOS(.v11)],
    products: [
        .library(name: "FeatureWithdrawalLocks", targets: [
            "FeatureWithdrawalLocksDomain",
            "FeatureWithdrawalLocksUI",
            "FeatureWithdrawalLocksData"
        ]),
        .library(name: "FeatureWithdrawalLocksDomain", targets: ["FeatureWithdrawalLocksDomain"]),
        .library(name: "FeatureWithdrawalLocksUI", targets: ["FeatureWithdrawalLocksUI"]),
        .library(name: "FeatureWithdrawalLocksData", targets: ["FeatureWithdrawalLocksData"])
    ],
    dependencies: [
        .package(
            name: "swift-composable-architecture",
            url: "https://github.com/pointfreeco/swift-composable-architecture",
            .exact("0.38.3")
        ),
        .package(
            name: "DIKit",
            url: "https://github.com/jackpooleybc/DIKit.git",
            .branch("safe-property-wrappers")
        ),
        .package(path: "../BlockchainComponentLibrary"),
        .package(path: "../ComposableArchitectureExtensions"),
        .package(path: "../Localization"),
        .package(path: "../UIComponents"),
        .package(path: "../Network"),
        .package(path: "../Errors"),
        .package(path: "../Tool")
    ],
    targets: [
        .target(
            name: "FeatureWithdrawalLocksDomain",
            dependencies: [
                .product(
                    name: "DIKit",
                    package: "DIKit"
                ),
                .product(
                    name: "ToolKit",
                    package: "Tool"
                )
            ]
        ),
        .target(
            name: "FeatureWithdrawalLocksData",
            dependencies: [
                .target(name: "FeatureWithdrawalLocksDomain"),
                .product(
                    name: "NetworkKit",
                    package: "Network"
                ),
                .product(
                    name: "Errors",
                    package: "Errors"
                ),
                .product(
                    name: "DIKit",
                    package: "DIKit"
                )
            ]
        ),
        .target(
            name: "FeatureWithdrawalLocksUI",
            dependencies: [
                .target(name: "FeatureWithdrawalLocksDomain"),
                .product(
                    name: "DIKit",
                    package: "DIKit"
                ),
                .product(
                    name: "BlockchainComponentLibrary",
                    package: "BlockchainComponentLibrary"
                ),
                .product(
                    name: "ComposableArchitecture",
                    package: "swift-composable-architecture"
                ),
                .product(
                    name: "ComposableNavigation",
                    package: "ComposableArchitectureExtensions"
                ),
                .product(
                    name: "Localization",
                    package: "Localization"
                ),
                .product(
                    name: "UIComponents",
                    package: "UIComponents"
                )
            ]
        ),
        .testTarget(
            name: "FeatureWithdrawalLocksDomainTests",
            dependencies: [
            ]
        ),
        .testTarget(
            name: "FeatureWithdrawalLocksDataTests",
            dependencies: [
            ]
        ),
        .testTarget(
            name: "FeatureWithdrawalLocksUITests",
            dependencies: [
            ]
        )
    ]
)
