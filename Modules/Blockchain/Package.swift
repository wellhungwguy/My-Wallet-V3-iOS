// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "Blockchain",
    platforms: [.macOS(.v11), .iOS(.v14)],
    products: [
        .library(name: "Blockchain", targets: ["Blockchain"]),
        .library(name: "BlockchainUI", targets: ["BlockchainUI"])
    ],
    dependencies: [
        .package(path: "../AnyCoding"),
        .package(path: "../BlockchainComponentLibrary"),
        .package(path: "../BlockchainNamespace"),
        .package(path: "../Errors"),
        .package(path: "../Extensions"),
        .package(path: "../Keychain"),
        .package(path: "../Money")
    ],
    targets: [
        .target(
            name: "Blockchain",
            dependencies: [
                .product(name: "AnyCoding", package: "AnyCoding"),
                .product(name: "BlockchainNamespace", package: "BlockchainNamespace"),
                .product(name: "Errors", package: "Errors"),
                .product(name: "Extensions", package: "Extensions"),
                .product(name: "KeychainKit", package: "Keychain"),
                .product(name: "MoneyKit", package: "Money")
            ]
        ),
        .target(
            name: "BlockchainUI",
            dependencies: [
                .target(name: "Blockchain"),
                .product(name: "BlockchainComponentLibrary", package: "BlockchainComponentLibrary"),
                .product(name: "ErrorsUI", package: "Errors")
            ]
        )
    ]
)
