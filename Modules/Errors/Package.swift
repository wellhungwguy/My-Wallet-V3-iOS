// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "Errors",
    platforms: [.iOS(.v14), .macOS(.v11)],
    products: [
        .library(
            name: "Errors",
            targets: ["Errors"]
        ),
        .library(
            name: "ErrorsUI",
            targets: ["ErrorsUI"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/pointfreeco/swift-snapshot-testing",
            from: "1.9.0"
        ),
        .package(
            url: "https://github.com/apple/swift-collections.git",
            from: "1.0.0"
        ),
        .package(path: "../BlockchainComponentLibrary"),
        .package(path: "../BlockchainNamespace"),
        .package(path: "../Localization"),
        .package(path: "../Tool")
    ],
    targets: [
        .target(
            name: "Errors",
            dependencies: [
                .product(name: "AnyCoding", package: "BlockchainNamespace"),
                .product(name: "BlockchainNamespace", package: "BlockchainNamespace"),
                .product(name: "BlockchainComponentLibrary", package: "BlockchainComponentLibrary"),
                .product(name: "Collections", package: "swift-collections"),
                .product(name: "ToolKit", package: "Tool"),
                .product(name: "Localization", package: "Localization")
            ]
        ),
        .target(
            name: "ErrorsUI",
            dependencies: [
                .target(name: "Errors")
            ]
        ),
        .testTarget(
            name: "ErrorsTests",
            dependencies: [
                .target(name: "Errors")
            ]
        ),

        .testTarget(
            name: "ErrorsUITests",
            dependencies: [
                .target(name: "ErrorsUI"),
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing")
            ],
            exclude: ["__Snapshots__"]
        )
    ]
)
