// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "CommonCrypto",
    platforms: [
        .iOS(.v14), .macOS(.v11)
    ],
    products: [
        .library(name: "CommonCryptoKit", targets: ["CommonCryptoKit"])
    ],
    dependencies: [
        .package(
            name: "CryptoSwift",
            url: "https://github.com/krzyzanowskim/CryptoSwift.git",
            from: "1.4.2"
        ),
        .package(
            name: "WalletCore",
            url: "https://github.com/oliveratkinson-bc/wallet-core.git",
            .exact("2.9.8-blockchain")
        ),
        .package(path: "../Test")
    ],
    targets: [
        .target(
            name: "CommonCryptoKit",
            dependencies: [
                .product(name: "WalletCore", package: "WalletCore"),
                .product(name: "SwiftProtobuf", package: "WalletCore"),
                .product(name: "CryptoSwift", package: "CryptoSwift")
            ],
            linkerSettings: [
                .linkedLibrary("c++")
            ]
        ),
        .testTarget(
            name: "CommonCryptoKitTests",
            dependencies: [
                "CommonCryptoKit",
                .product(name: "TestKit", package: "Test")
            ]
        )
    ]
)
