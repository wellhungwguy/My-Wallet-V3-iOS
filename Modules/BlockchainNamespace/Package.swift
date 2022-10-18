// swift-tools-version: 5.7

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
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/thousandyears/Lexicon.git",
            from: "0.6.1"
        ),
        .package(path: "../Extensions"),
        .package(path: "../AnyCoding")
    ],
    targets: [
        .target(
            name: "BlockchainNamespace",
            dependencies: [
                .target(name: "FirebaseProtocol"),
                .product(name: "Lexicon", package: "Lexicon"),
                .product(name: "AnyCoding", package: "AnyCoding"),
                .product(name: "Extensions", package: "Extensions")
            ],
            resources: [
                .copy("blockchain.taskpaper")
            ]
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
        )
    ]
)
