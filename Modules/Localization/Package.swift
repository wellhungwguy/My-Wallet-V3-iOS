// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "Localization",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
        .watchOS(.v7),
        .tvOS(.v14)
    ],
    products: [
        .library(name: "Localization", targets: ["Localization"])
    ],
    targets: [
        .target(name: "Localization")
    ]
)
