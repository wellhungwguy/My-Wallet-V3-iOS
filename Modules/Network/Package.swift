// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Network",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
        .watchOS(.v7),
        .tvOS(.v14)
    ],
    products: [
        .library(
            name: "NetworkKit",
            targets: ["NetworkKit"]
        ),
        .library(
            name: "NetworkKitMock",
            targets: ["NetworkKitMock"]
        )
    ],
    dependencies: [
        .package(
            name: "DIKit",
            url: "https://github.com/jackpooleybc/DIKit.git",
            .branch("safe-property-wrappers")
        ),
        .package(name: "Analytics", path: "../Analytics"),
        .package(name: "Test", path: "../Test"),
        .package(name: "Tool", path: "../Tool"),
        .package(name: "Errors", path: "../Errors")
    ],
    targets: [
        .target(
            name: "NetworkKit",
            dependencies: [
                .product(name: "AnalyticsKit", package: "Analytics"),
                .product(name: "ToolKit", package: "Tool"),
                .product(name: "DIKit", package: "DIKit"),
                .product(name: "Errors", package: "Errors")
            ]
        ),
        .target(
            name: "NetworkKitMock",
            dependencies: [
                .target(name: "NetworkKit"),
                .product(name: "AnalyticsKit", package: "Analytics"),
                .product(name: "DIKit", package: "DIKit"),
                .product(name: "TestKit", package: "Test"),
                .product(name: "ToolKit", package: "Tool")
            ]
        ),
        .testTarget(
            name: "NetworkKitTests",
            dependencies: [
                .target(name: "NetworkKit"),
                .product(name: "TestKit", package: "Test")
            ]
        )
    ]
)
