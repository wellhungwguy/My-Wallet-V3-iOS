// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "FeatureForm",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(name: "FeatureForm", targets: ["FeatureFormDomain", "FeatureFormUI"]),
        .library(name: "FeatureFormDomain", targets: ["FeatureFormDomain"]),
        .library(name: "FeatureFormUI", targets: ["FeatureFormUI"])
    ],
    dependencies: [
        .package(
            name: "swift-composable-architecture",
            url: "https://github.com/pointfreeco/swift-composable-architecture",
            from: "0.34.0"
        ),
        .package(path: "../BlockchainComponentLibrary"),
        .package(path: "../Tool")
    ],
    targets: [
        .target(
            name: "FeatureFormDomain",
            dependencies: [
                .product(name: "ToolKit", package: "Tool")
            ]
        ),
        .target(
            name: "FeatureFormUI",
            dependencies: [
                .product(name: "BlockchainComponentLibrary", package: "BlockchainComponentLibrary"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .target(name: "FeatureFormDomain")
            ]
        )
    ]
)
