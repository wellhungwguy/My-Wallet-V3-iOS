// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "BlockchainComponentLibrary",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
        .watchOS(.v7),
        .tvOS(.v14)
    ],
    products: [
        .library(
            name: "BlockchainComponentLibrary",
            targets: [
                "BlockchainComponentLibrary"
            ]
        ),
        .library(
            name: "Examples",
            targets: [
                "Examples"
            ]
        )
    ],
    dependencies: [
        .package(
            name: "SnapshotTesting",
            url: "https://github.com/pointfreeco/swift-snapshot-testing",
            from: "1.9.0"
        ),
        .package(
            name: "swift-case-paths",
            url: "https://github.com/pointfreeco/swift-case-paths",
            from: "0.8.0"
        ),
        .package(
            name: "swift-markdown",
            url: "https://github.com/apple/swift-markdown.git",
            .revision("1023300b1d6847360ac9ceebbcff2bccacbcf2a5")
        ),
        .package(
            name: "swift-algorithms",
            url: "https://github.com/apple/swift-algorithms.git",
            from: "1.0.0"
        ),
        .package(
            name: "Lottie",
            url: "https://github.com/airbnb/lottie-ios.git",
            from: "3.3.0"
        ),
        .package(
            name: "NukeUI",
            url: "https://github.com/kean/NukeUI.git",
            from: "0.8.3"
        )
    ],
    targets: [
        .target(
            name: "BlockchainComponentLibrary",
            dependencies: [
                .product(name: "Algorithms", package: "swift-algorithms"),
                .product(name: "CasePaths", package: "swift-case-paths"),
                .product(name: "Markdown", package: "swift-markdown"),
                .product(name: "Lottie", package: "Lottie"),
                .product(name: "NukeUI", package: "NukeUI")
            ],
            resources: [
                .process("Resources/Fonts"),
                .copy("Resources/Animation/loader.json")
            ]
        ),
        .testTarget(
            name: "BlockchainComponentLibraryTests",
            dependencies: [
                "BlockchainComponentLibrary",
                "SnapshotTesting",
                "Examples"
            ],
            exclude: [
                "1 - Base/__Snapshots__",
                "2 - Primitives/__Snapshots__",
                "2 - Primitives/Buttons/__Snapshots__",
                "3 - Compositions/__Snapshots__",
                "3 - Compositions/Rows/__Snapshots__",
                "3 - Compositions/SectionHeaders/__Snapshots__",
                "3 - Compositions/Sheets/__Snapshots__",
                "Utilities/__Snapshots__"
            ]
        ),
        .target(
            name: "Examples",
            dependencies: [
                "BlockchainComponentLibrary"
            ]
        )
    ]
)
