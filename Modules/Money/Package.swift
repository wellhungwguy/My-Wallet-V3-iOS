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
            url: "https://github.com/jackpooleybc/DIKit.git",
            branch: "safe-property-wrappers"
        ),
        .package(path: "../Tool"),
        .package(path: "../Localization")
    ],
    targets: [
        .target(
            name: "MoneyKit",
            dependencies: [
                .product(name: "BigInt", package: "BigInt"),
                .product(name: "DIKit", package: "DIKit"),
                .product(name: "ToolKit", package: "Tool"),
                .product(name: "Localization", package: "Localization")
            ],
            resources: [
                .copy("Resources/local-currencies-custodial.json"),
                .copy("Resources/local-currencies-ethereum-erc20.json"),
                .copy("Resources/local-currencies-polygon-erc20.json")
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
