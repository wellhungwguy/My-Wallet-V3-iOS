// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "Extensions",
    platforms: [.iOS(.v14), .macOS(.v11)],
    products: [
        .library(name: "Extensions", targets: ["Extensions"]),
        .library(name: "CombineExtensions", targets: ["CombineExtensions"]),
        .library(name: "SwiftExtensions", targets: ["SwiftExtensions"]),
        .library(name: "SwiftUIExtensions", targets: ["SwiftUIExtensions"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/apple/swift-algorithms.git",
            from: "1.0.0"
        ),
        .package(
            url: "https://github.com/apple/swift-collections.git",
            from: "1.0.0"
        ),
        .package(
            url: "https://github.com/pointfreeco/combine-schedulers",
            from: "0.7.0"
        ),
        .package(
            url: "https://github.com/pointfreeco/swift-case-paths",
            from: "0.9.1"
        )
    ],
    targets: [
        .target(
            name: "Extensions",
            dependencies: [
                "AsyncExtensions",
                "CombineExtensions",
                "SwiftExtensions",
                "SwiftUIExtensions"
            ]
        ),
        .target(
            name: "AsyncExtensions",
            dependencies: ["SwiftExtensions"]
        ),
        .target(
            name: "CombineExtensions",
            dependencies: [
                .target(name: "SwiftExtensions"),
                .product(name: "CombineSchedulers", package: "combine-schedulers"),
            ]
        ),
        .target(
            name: "SwiftExtensions",
            dependencies: [
                .product(name: "Algorithms", package: "swift-algorithms"),
                .product(name: "Collections", package: "swift-collections"),
                .product(name: "CasePaths", package: "swift-case-paths")
            ]
        ),
        .target(
            name: "SwiftUIExtensions",
            dependencies: ["SwiftExtensions"]
        ),
        .testTarget(
            name: "ExtensionsTests",
            dependencies: ["Extensions"]
        ),
        .testTarget(
            name: "AsyncExtensionsTests",
            dependencies: ["AsyncExtensions"]
        ),
        .testTarget(
            name: "CombineExtensionsTests",
            dependencies: ["CombineExtensions"]
        ),
        .testTarget(
            name: "SwiftExtensionsTests",
            dependencies: ["SwiftExtensions"]
        ),
    ]
)
