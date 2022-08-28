// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "RxAnalytics",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
        .watchOS(.v7),
        .tvOS(.v14)
    ],
    products: [
        .library(
            name: "RxAnalyticsKit",
            targets: ["RxAnalyticsKit"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/ReactiveX/RxSwift.git",
            from: "6.2.0"
        ),
        .package(path: "../Analytics")
    ],
    targets: [
        .target(
            name: "RxAnalyticsKit",
            dependencies: [
                .product(name: "AnalyticsKit", package: "Analytics"),
                .product(name: "RxSwift", package: "RxSwift")
            ]
        )
    ]
)
