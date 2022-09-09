// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Tool",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
        .watchOS(.v7),
        .tvOS(.v14)
    ],
    products: [
        .library(
            name: "ToolKit",
            targets: ["ToolKit"]
        ),
        .library(
            name: "ToolKitMock",
            targets: ["ToolKitMock"]
        )
    ],
    dependencies: [
        .package(
            name: "DIKit",
            url: "https://github.com/jackpooleybc/DIKit.git",
            .branch("safe-property-wrappers")
        ),
        .package(
            name: "BigInt",
            url: "https://github.com/attaswift/BigInt.git",
            from: "5.3.0"
        ),
        .package(path: "../Test"),
        .package(path: "../Extensions")
    ],
    targets: [
        .target(
            name: "ToolKit",
            dependencies: [
                .product(name: "DIKit", package: "DIKit"),
                .product(name: "BigInt", package: "BigInt"),
                .product(name: "Extensions", package: "Extensions")
            ]
        ),
        .target(
            name: "ToolKitMock",
            dependencies: [
                .target(name: "ToolKit")
            ]
        ),
        .testTarget(
            name: "ToolKitTests",
            dependencies: [
                .target(name: "ToolKit"),
                .target(name: "ToolKitMock"),
                .product(name: "TestKit", package: "Test")
            ]
        )
    ]
)
