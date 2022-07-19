// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DelegatedSelfCustody",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
        .watchOS(.v7),
        .tvOS(.v14)
    ],
    products: [
        .library(
            name: "DelegatedSelfCustodyKit",
            targets: ["DelegatedSelfCustodyDomain", "DelegatedSelfCustodyData"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/jackpooleybc/DIKit.git",
            branch: "safe-property-wrappers"
        ),
        .package(
            url: "https://github.com/krzyzanowskim/CryptoSwift.git",
            from: "1.4.2"
        ),
        .package(path: "../BlockchainNamespace"),
        .package(path: "../Money"),
        .package(path: "../Network"),
        .package(path: "../Test"),
        .package(path: "../Tool")
    ],
    targets: [
        .target(
            name: "DelegatedSelfCustodyDomain",
            dependencies: [
                .product(name: "DIKit", package: "DIKit"),
                .product(name: "MoneyKit", package: "Money"),
                .product(name: "ToolKit", package: "Tool")
            ]
        ),
        .target(
            name: "DelegatedSelfCustodyData",
            dependencies: [
                .target(name: "DelegatedSelfCustodyDomain"),
                .product(name: "CryptoSwift", package: "CryptoSwift"),
                .product(name: "BlockchainNamespace", package: "BlockchainNamespace"),
                .product(name: "DIKit", package: "DIKit"),
                .product(name: "MoneyKit", package: "Money"),
                .product(name: "NetworkKit", package: "Network"),
                .product(name: "ToolKit", package: "Tool")
            ]
        ),
        .testTarget(
            name: "DelegatedSelfCustodyDataTests",
            dependencies: [
                .target(name: "DelegatedSelfCustodyData"),
                .target(name: "DelegatedSelfCustodyDomain"),
                .product(name: "TestKit", package: "Test")
            ]
        )
    ]
)
