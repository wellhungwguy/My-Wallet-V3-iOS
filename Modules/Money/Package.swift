// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "Money",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
        .watchOS(.v7),
        .tvOS(.v14)
    ],
    products: [
        .library(
            name: "MoneyKit",
            targets: ["MoneyKit"]
        ),
        .library(
            name: "MoneyKitMock",
            targets: ["MoneyKitMock"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/attaswift/BigInt.git",
            from: "5.3.0"
        ),
        .package(
            url: "https://github.com/dchatzieleftheriou-bc/DIKit.git",
            branch: "safe-property-wrappers-locks"
        ),
        .package(path: "../Tool"),
        .package(path: "../Localization"),
        .package(path: "../Network")
    ],
    targets: [
        .target(
            name: "MoneyKit",
            dependencies: [
                .product(name: "BigInt", package: "BigInt"),
                .product(name: "DIKit", package: "DIKit"),
                .product(name: "Localization", package: "Localization"),
                .product(name: "NetworkKit", package: "Network"),
                .product(name: "ToolKit", package: "Tool")
            ],
            resources: [
                .copy("Resources/local-currencies-custodial.json"),
                .copy("Resources/local-currencies-ethereum-erc20.json"),
                .copy("Resources/local-currencies-other-erc20.json")
            ]
        ),
        .target(
            name: "MoneyKitMock",
            dependencies: [
                .target(name: "MoneyKit")
            ]
        ),
        .testTarget(
            name: "MoneyKitTests",
            dependencies: [
                .target(name: "MoneyKit"),
                .target(name: "MoneyKitMock")
            ]
        )
    ]
)
