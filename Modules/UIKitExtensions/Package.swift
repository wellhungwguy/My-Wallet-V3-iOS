// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "UIKitExtensions",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "UIKitExtensions",
            targets: [
                "UIKitExtensions"
            ]
        )
    ],
    dependencies: [
        .package(path: "../Tool")
    ],
    targets: [
        .target(
            name: "UIKitExtensions",
            dependencies: [
                .product(
                    name: "ToolKit",
                    package: "Tool"
                )
            ]
        )
    ]
)
