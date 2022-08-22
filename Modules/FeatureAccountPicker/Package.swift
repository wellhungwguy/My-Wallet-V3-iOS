// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "FeatureAccountPicker",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
        .watchOS(.v7),
        .tvOS(.v14)
    ],
    products: [
        .library(
            name: "FeatureAccountPicker",
            targets: [
                "FeatureAccountPickerData",
                "FeatureAccountPickerDomain",
                "FeatureAccountPickerUI"
            ]
        )
    ],
    dependencies: [
        .package(
            name: "swift-composable-architecture",
            url: "https://github.com/pointfreeco/swift-composable-architecture",
            .exact("0.38.3")
        ),
        .package(
            name: "SnapshotTesting",
            url: "https://github.com/pointfreeco/swift-snapshot-testing",
            from: "1.9.0"
        ),
        .package(url: "https://github.com/pointfreeco/combine-schedulers", from: "0.1.2"),
        .package(path: "../UIComponents"),
        .package(path: "../Test"),
        .package(path: "../Platform"),
        .package(path: "../Localization"),
        .package(path: "../ComposableArchitectureExtensions")
    ],
    targets: [
        .target(
            name: "FeatureAccountPickerData",
            dependencies: [
                .target(name: "FeatureAccountPickerDomain")
            ],
            path: "Data"
        ),
        .target(
            name: "FeatureAccountPickerDomain",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ],
            path: "Domain"
        ),
        .target(
            name: "FeatureAccountPickerUI",
            dependencies: [
                .target(name: "FeatureAccountPickerDomain"),
                .product(name: "Localization", package: "Localization"),
                .product(name: "UIComponents", package: "UIComponents"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "CombineSchedulers", package: "combine-schedulers"),
                .product(name: "ComposableNavigation", package: "ComposableArchitectureExtensions"),
                .product(name: "ComposableArchitectureExtensions", package: "ComposableArchitectureExtensions")
            ],
            path: "UI"
        ),
        .testTarget(
            name: "FeatureAccountPickerTests",
            dependencies: [
                .target(name: "FeatureAccountPickerData"),
                .target(name: "FeatureAccountPickerDomain"),
                .target(name: "FeatureAccountPickerUI"),
                .product(name: "SnapshotTesting", package: "SnapshotTesting"),
                .product(name: "TestKit", package: "Test"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "PlatformKit", package: "Platform"),
                .product(name: "PlatformKitMock", package: "Platform"),
                .product(name: "PlatformUIKit", package: "Platform"),
                .product(name: "UIComponents", package: "UIComponents")
            ],
            path: "Tests",
            exclude: ["__Snapshots__"]
        )
    ]
)
