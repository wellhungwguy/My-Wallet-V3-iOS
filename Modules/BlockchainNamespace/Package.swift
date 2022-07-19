// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "BlockchainNamespace",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
        .watchOS(.v7),
        .tvOS(.v14)
    ],
    products: [
        .library(
            name: "BlockchainNamespace",
            targets: ["BlockchainNamespace"]
        ),
        .library(
            name: "AnyCoding",
            targets: ["AnyCoding"]
        ),
        .executable(
            name: "gen",
            targets: ["gen"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/screensailor/Lexicon",
            revision: "160c4c417f8490658a8396d0283fb0d6fb98c327"
        ),
        .package(
            url: "https://github.com/apple/swift-algorithms.git",
            from: "1.0.0"
        )
    ],
    targets: [
        .executableTarget(
            name: "gen",
            dependencies: [
                .product(name: "Lexicon", package: "Lexicon"),
                .product(name: "SwiftStandAlone", package: "Lexicon")
            ]
        ),
        .target(
            name: "BlockchainNamespace",
            dependencies: [
                .target(name: "AnyCoding"),
                .target(name: "FirebaseProtocol"),
                .product(name: "Algorithms", package: "swift-algorithms"),
                .product(name: "Lexicon", package: "Lexicon")
            ],
            resources: [
                .copy("blockchain.taskpaper")
            ]
        ),
        .target(
            name: "AnyCoding"
        ),
        .target(
            name: "FirebaseProtocol"
        ),
        .testTarget(
            name: "BlockchainNamespaceTests",
            dependencies: ["BlockchainNamespace"],
            resources: [
                .copy("test.taskpaper")
            ]
        ),
        .testTarget(
            name: "AnyCodingTests",
            dependencies: ["AnyCoding"]
        )
    ]
)
