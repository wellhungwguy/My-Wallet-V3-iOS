// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "FeatureTour",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "FeatureTour",
            targets: [
                "FeatureTourData",
                "FeatureTourDomain",
                "FeatureTourUI"
            ]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "0.24.0"),
        .package(
            name: "SnapshotTesting",
            url: "https://github.com/pointfreeco/swift-snapshot-testing",
            from: "1.9.0"
        ),
        .package(name: "NukeUI", url: "https://github.com/kean/NukeUI.git", from: "0.8.3"),
        .package(name: "DIKit", url: "https://github.com/jackpooleybc/DIKit.git", .branch("safe-property-wrappers")),
        .package(path: "../Localization"),
        .package(path: "../Platform"),
        .package(path: "../UIComponents"),
        .package(path: "../ComposableArchitectureExtensions")
    ],
    targets: [
        .target(
            name: "FeatureTourData",
            dependencies: [
                "FeatureTourDomain"
            ],
            path: "Data"
        ),
        .target(
            name: "FeatureTourDomain",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ],
            path: "Domain"
        ),
        .target(
            name: "FeatureTourUI",
            dependencies: [
                .target(name: "FeatureTourDomain"),
                .product(name: "Localization", package: "Localization"),
                .product(name: "PlatformKit", package: "Platform"),
                .product(name: "PlatformUIKit", package: "Platform"),
                .product(name: "UIComponents", package: "UIComponents"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "NukeUI", package: "NukeUI"),
                .product(name: "ComposableNavigation", package: "ComposableArchitectureExtensions")
            ],
            path: "UI"
        ),
        .testTarget(
            name: "FeatureTourTests",
            dependencies: [
                .target(name: "FeatureTourData"),
                .target(name: "FeatureTourDomain"),
                .target(name: "FeatureTourUI"),
                .product(name: "SnapshotTesting", package: "SnapshotTesting"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "DIKit", package: "DIKit")
            ],
            path: "Tests",
            exclude: ["__Snapshots__"]
        )
    ]
)
