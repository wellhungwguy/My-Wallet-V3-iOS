// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Test",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
        .watchOS(.v7),
        .tvOS(.v14)
    ],
    products: [
        .library(
            name: "TestKit",
            targets: ["TestKit"]
        )
    ],
    dependencies: [
        .package(
            name: "combine-schedulers",
            url: "https://github.com/pointfreeco/combine-schedulers",
            from: "0.5.0"
        ),
        .package(
            name: "SnapshotTesting",
            url: "https://github.com/pointfreeco/swift-snapshot-testing",
            from: "1.9.0"
        )
    ],
    targets: [
        .target(
            name: "TestKit",
            dependencies: [
                .product(name: "CombineSchedulers", package: "combine-schedulers"),
                .product(name: "SnapshotTesting", package: "SnapshotTesting")
            ]
        )
    ]
)
