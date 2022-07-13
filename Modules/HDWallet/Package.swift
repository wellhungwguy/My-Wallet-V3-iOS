// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "HDWallet",
    platforms: [.iOS(.v14)],
    products: [
        .library(name: "HDWalletKit", targets: ["HDWalletKit"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/pointfreeco/swift-parsing",
            from: "0.10.0"
        ),
        .package(path: "../CommonCrypto"),
        .package(path: "../Tool")
    ],
    targets: [
        .target(
            name: "HDWalletKit",
            dependencies: [
                .product(name: "Parsing", package: "swift-parsing"),
                .product(name: "CommonCryptoKit", package: "CommonCrypto"),
                .product(name: "ToolKit", package: "Tool")
            ]
        ),
        .testTarget(
            name: "HDWalletKitTests",
            dependencies: ["HDWalletKit"]
        )
    ]
)
