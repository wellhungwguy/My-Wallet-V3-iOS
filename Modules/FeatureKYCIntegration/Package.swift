// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FeatureKYCIntegration",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
        .watchOS(.v7),
        .tvOS(.v14)
    ],
    products: [
        .library(
            name: "FeatureProveData",
            targets: ["FeatureProveData"]
        ),
        .library(
            name: "FeatureProveDomain",
            targets: ["FeatureProveDomain"]
        ),
        .library(
            name: "FeatureProveUI",
            targets: ["FeatureProveUI"]
        )
    ],
    dependencies: [
        .package(path: "../Blockchain"),
        .package(path: "../Network"),
        .package(path: "../Test")
    ],
    targets: [
        .target(
            name: "FeatureProveData",
            dependencies: [
                .target(name: "FeatureProveDomain"),
                .product(name: "Blockchain", package: "Blockchain"),
                .product(name: "NetworkKit", package: "Network")
            ],
            path: "./Sources/FeatureProve/FeatureProveData"
        ),
        .target(
            name: "FeatureProveDomain",
            dependencies: [
                .product(name: "Blockchain", package: "Blockchain")
            ],
            path: "./Sources/FeatureProve/FeatureProveDomain"
        ),
        .target(
            name: "FeatureProveUI",
            dependencies: [
                .target(name: "FeatureProveDomain"),
                .product(name: "Blockchain", package: "Blockchain"),
                .product(name: "BlockchainUI", package: "Blockchain")
            ],
            path: "./Sources/FeatureProve/FeatureProveUI"
        ),
        .testTarget(
            name: "FeatureProveTests",
            dependencies: [
                .target(name: "FeatureProveDomain"),
                .product(name: "TestKit", package: "Test")
            ]
        )
    ]
)
