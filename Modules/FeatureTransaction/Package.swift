// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "FeatureTransaction",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "FeatureTransaction",
            targets: ["FeatureTransactionDomain", "FeatureTransactionData", "FeatureTransactionUI"]
        ),
        .library(
            name: "FeatureTransactionDomain",
            targets: ["FeatureTransactionDomain"]
        ),
        .library(
            name: "FeatureTransactionData",
            targets: ["FeatureTransactionData"]
        ),
        .library(
            name: "FeatureTransactionUI",
            targets: ["FeatureTransactionUI"]
        ),
        .library(
            name: "FeatureTransactionDomainMock",
            targets: ["FeatureTransactionDomainMock"]
        ),
        .library(
            name: "FeatureTransactionUIMock",
            targets: ["FeatureTransactionUIMock"]
        )
    ],
    dependencies: [
        .package(
            name: "swift-composable-architecture",
            url: "https://github.com/pointfreeco/swift-composable-architecture",
            from: "0.34.0"
        ),
        .package(
            name: "swift-algorithms",
            url: "https://github.com/apple/swift-algorithms.git",
            from: "1.0.0"
        ),
        .package(
            name: "Nuke",
            url: "https://github.com/kean/Nuke.git",
            from: "10.3.1"
        ),
        .package(
            name: "NukeUI",
            url: "https://github.com/kean/NukeUI.git",
            from: "0.6.5"
        ),
        .package(
            name: "BigInt",
            url: "https://github.com/attaswift/BigInt.git",
            from: "5.2.1"
        ),
        .package(
            name: "DIKit",
            url: "https://github.com/jackpooleybc/DIKit.git",
            .branch("safe-property-wrappers")
        ),
        .package(
            name: "RxSwift",
            url: "https://github.com/ReactiveX/RxSwift.git",
            from: "6.2.0"
        ),
        .package(
            name: "RxDataSources",
            url: "https://github.com/RxSwiftCommunity/RxDataSources.git",
            from: "5.0.2"
        ),
        .package(
            name: "RIBs",
            url: "https://github.com/uber/RIBs.git",
            from: "0.12.1"
        ),
        .package(path: "../Analytics"),
        .package(path: "../BlockchainComponentLibrary"),
        .package(path: "../BlockchainNamespace"),
        .package(path: "../FeatureKYC"),
        .package(path: "../FeatureProducts"),
        .package(path: "../Localization"),
        .package(path: "../Network"),
        .package(path: "../Errors"),
        .package(path: "../Platform"),
        .package(path: "../Test"),
        .package(path: "../Tool"),
        .package(path: "../UIComponents"),
        .package(path: "Modules/BIND")
    ],
    targets: [
        .target(
            name: "FeatureTransactionDomain",
            dependencies: [
                .product(name: "Algorithms", package: "swift-algorithms"),
                .product(name: "BigInt", package: "BigInt"),
                .product(name: "DIKit", package: "DIKit"),
                .product(name: "Localization", package: "Localization"),
                .product(name: "Errors", package: "Errors"),
                .product(name: "PlatformKit", package: "Platform"),
                .product(name: "FeatureProductsDomain", package: "FeatureProducts"),
                .product(name: "RxSwift", package: "RxSwift"),
                .product(name: "ToolKit", package: "Tool")
            ]
        ),
        .target(
            name: "FeatureTransactionData",
            dependencies: [
                .target(name: "FeatureTransactionDomain"),
                .product(name: "DIKit", package: "DIKit"),
                .product(name: "NetworkKit", package: "Network"),
                .product(name: "PlatformKit", package: "Platform"),
                .product(name: "RxSwift", package: "RxSwift"),
                .product(name: "ToolKit", package: "Tool"),
                .product(name: "BINDWithdrawData", package: "BIND")
            ]
        ),
        .target(
            name: "FeatureTransactionUI",
            dependencies: [
                .target(name: "FeatureTransactionDomain"),
                .product(name: "AnalyticsKit", package: "Analytics"),
                .product(name: "BlockchainComponentLibrary", package: "BlockchainComponentLibrary"),
                .product(name: "BlockchainNamespace", package: "BlockchainNamespace"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "FeatureKYCDomain", package: "FeatureKYC"),
                .product(name: "FeatureKYCUI", package: "FeatureKYC"),
                .product(name: "Localization", package: "Localization"),
                .product(name: "Nuke", package: "Nuke"),
                .product(name: "NukeUI", package: "NukeUI"),
                .product(name: "PlatformKit", package: "Platform"),
                .product(name: "PlatformUIKit", package: "Platform"),
                .product(name: "RIBs", package: "RIBs"),
                .product(name: "RxCocoa", package: "RxSwift"),
                .product(name: "RxDataSources", package: "RxDataSources"),
                .product(name: "RxRelay", package: "RxSwift"),
                .product(name: "RxSwift", package: "RxSwift"),
                .product(name: "UIComponents", package: "UIComponents"),
                .product(name: "ErrorsUI", package: "Errors"),
                .product(name: "BINDWithdrawUI", package: "BIND"),
                .product(name: "BINDWithdrawDomain", package: "BIND")
            ]
        ),
        .target(
            name: "FeatureTransactionDomainMock",
            dependencies: [
                .target(name: "FeatureTransactionDomain"),
                .product(name: "PlatformKit", package: "Platform"),
                .product(name: "ToolKit", package: "Tool")
            ]
        ),
        .target(
            name: "FeatureTransactionUIMock",
            dependencies: [
                .target(name: "FeatureTransactionUI"),
                .product(name: "ToolKit", package: "Tool")
            ]
        ),
        .testTarget(
            name: "FeatureTransactionDomainTests",
            dependencies: [
                .target(name: "FeatureTransactionDomain"),
                .target(name: "FeatureTransactionDomainMock"),
                .product(name: "BigInt", package: "BigInt"),
                .product(name: "RxSwift", package: "RxSwift"),
                .product(name: "RxTest", package: "RxSwift"),
                .product(name: "TestKit", package: "Test"),
                .product(name: "PlatformKit", package: "Platform"),
                .product(name: "PlatformKitMock", package: "Platform"),
                .product(name: "FeatureProductsDomain", package: "FeatureProducts")
            ]
        ),
        .testTarget(
            name: "FeatureTransactionDataTests",
            dependencies: [
                .target(name: "FeatureTransactionData"),
                .product(name: "TestKit", package: "Test")
            ]
        ),
        .testTarget(
            name: "FeatureTransactionUITests",
            dependencies: [
                .target(name: "FeatureTransactionDomainMock"),
                .target(name: "FeatureTransactionUI"),
                .target(name: "FeatureTransactionUIMock"),
                .product(name: "AnalyticsKitMock", package: "Analytics"),
                .product(name: "PlatformKit", package: "Platform"),
                .product(name: "PlatformKitMock", package: "Platform"),
                .product(name: "PlatformUIKitMock", package: "Platform"),
                .product(name: "TestKit", package: "Test"),
                .product(name: "ToolKitMock", package: "Tool")
            ]
        )
    ]
)
