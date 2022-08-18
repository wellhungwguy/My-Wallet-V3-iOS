// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "AnyCoding",
    platforms: [.macOS(.v11), .iOS(.v14)],
    products: [
        .library(name: "AnyCoding", targets: ["AnyCoding"]),
    ],
    dependencies: [
        .package(path: "../Extensions")
    ],
    targets: [
        .target(
            name: "AnyCoding",
            dependencies: [
                .product(name: "SwiftExtensions", package: "Extensions")
            ]
        ),
        .testTarget(
            name: "AnyCodingTests",
            dependencies: ["AnyCoding"]
        )
    ]
)
