// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Blockchain",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "AnalyticsKit",
            targets: ["AnalyticsKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/CombineCommunity/CombineExt", from: "1.2.0"),
    ],
    targets: [
        .target(
            name: "AnalyticsKit",
            path: "Modules/Analytics/AnalyticsKit"
        ),
        .testTarget(
            name: "AnalyticsKitTests",
            path: "Modules/Analytics/AnalyticsKitTests"
        )
    ],
    swiftLanguageVersions: [.v5]
)
