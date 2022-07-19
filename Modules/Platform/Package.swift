// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "Platform",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
        .watchOS(.v7),
        .tvOS(.v14)
    ],
    products: [
        .library(name: "PlatformKit", targets: ["PlatformKit"]),
        .library(name: "PlatformDataKit", targets: ["PlatformDataKit"]),
        .library(name: "PlatformUIKit", targets: ["PlatformUIKit"]),
        .library(name: "PlatformKitMock", targets: ["PlatformKitMock"]),
        .library(name: "PlatformUIKitMock", targets: ["PlatformUIKitMock"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/attaswift/BigInt.git",
            from: "5.2.1"
        ),
        .package(
            url: "https://github.com/danielgindi/Charts.git",
            from: "3.6.0"
        ),
        .package(
            url: "https://github.com/jackpooleybc/DIKit.git",
            branch: "safe-property-wrappers"
        ),
        .package(
            url: "https://github.com/uber/RIBs.git",
            from: "0.12.1"
        ),
        .package(
            url: "https://github.com/RxSwiftCommunity/RxDataSources.git",
            from: "5.0.2"
        ),
        .package(
            url: "https://github.com/ReactiveX/RxSwift.git",
            from: "6.2.0"
        ),
        .package(
            url: "https://github.com/kean/Nuke.git",
            from: "10.11.2"
        ),
        .package(
            url: "https://github.com/marmelroy/PhoneNumberKit.git",
            from: "3.3.3"
        ),
        .package(
            url: "https://github.com/oliveratkinson-bc/zxcvbn-ios.git",
            branch: "swift-package-manager"
        ),
        .package(
            url: "https://github.com/apple/swift-algorithms.git",
            from: "1.0.0"
        ),
        .package(path: "../Analytics"),
        .package(path: "../RxAnalytics"),
        .package(path: "../FeatureAuthentication"),
        .package(path: "../CommonCrypto"),
        .package(path: "../DelegatedSelfCustody"),
        .package(path: "../Localization"),
        .package(path: "../Errors"),
        .package(path: "../Network"),
        .package(path: "../Money"),
        .package(path: "../Test"),
        .package(path: "../Tool"),
        .package(path: "../RxTool"),
        .package(path: "../WalletPayload"),
        .package(path: "../UIComponents"),
        .package(path: "../FeatureOpenBanking"),
        .package(path: "../ComposableArchitectureExtensions"),
        .package(path: "../BlockchainComponentLibrary"),
        .package(path: "../BlockchainNamespace"),
        .package(path: "../FeatureWithdrawalLocks"),
        .package(path: "../FeatureForm"),
        .package(path: "../FeatureCardPayment")
    ],
    targets: [
        .target(
            name: "PlatformKit",
            dependencies: [
                .product(name: "BigInt", package: "BigInt"),
                .product(name: "DIKit", package: "DIKit"),
                .product(name: "RxCocoa", package: "RxSwift"),
                .product(name: "RxSwift", package: "RxSwift"),
                .product(name: "AnalyticsKit", package: "Analytics"),
                .product(name: "DelegatedSelfCustodyKit", package: "DelegatedSelfCustody"),
                // TODO: refactor this to use `FeatureAuthenticationDomain` as this shouldn't depend on DataKit
                .product(name: "FeatureAuthenticationData", package: "FeatureAuthentication"),
                .product(name: "FeatureAuthenticationDomain", package: "FeatureAuthentication"),
                .product(name: "FeatureFormDomain", package: "FeatureForm"),
                .product(name: "CommonCryptoKit", package: "CommonCrypto"),
                .product(name: "Localization", package: "Localization"),
                .product(name: "Errors", package: "Errors"),
                .product(name: "NetworkKit", package: "Network"),
                .product(name: "MoneyKit", package: "Money"),
                .product(name: "ToolKit", package: "Tool"),
                .product(name: "ComposableNavigation", package: "ComposableArchitectureExtensions"),
                .product(name: "ComposableArchitectureExtensions", package: "ComposableArchitectureExtensions"),
                .product(name: "RxToolKit", package: "RxTool"),
                .product(name: "WalletPayloadKit", package: "WalletPayload"),
                .product(name: "FeatureOpenBankingDomain", package: "FeatureOpenBanking"),
                .product(name: "Algorithms", package: "swift-algorithms"),
                .product(name: "FeatureCardPaymentDomain", package: "FeatureCardPayment")
            ]
        ),
        .target(
            name: "PlatformDataKit",
            dependencies: [
                .target(name: "PlatformKit"),
                .product(name: "BigInt", package: "BigInt"),
                .product(name: "DIKit", package: "DIKit"),
                .product(name: "Errors", package: "Errors"),
                .product(name: "NetworkKit", package: "Network"),
                .product(name: "ToolKit", package: "Tool"),
                .product(name: "FeatureCardPaymentDomain", package: "FeatureCardPayment")
            ]
        ),
        .target(
            name: "PlatformUIKit",
            dependencies: [
                .target(name: "PlatformKit"),
                .product(name: "RIBs", package: "RIBs"),
                .product(name: "RxDataSources", package: "RxDataSources"),
                .product(name: "RxAnalyticsKit", package: "RxAnalytics"),
                .product(name: "Charts", package: "Charts"),
                .product(name: "UIComponents", package: "UIComponents"),
                .product(name: "Nuke", package: "Nuke"),
                .product(name: "PhoneNumberKit", package: "PhoneNumberKit"),
                .product(name: "Zxcvbn", package: "zxcvbn-ios"),
                .product(name: "FeatureOpenBankingUI", package: "FeatureOpenBanking"),
                .product(name: "BlockchainComponentLibrary", package: "BlockchainComponentLibrary"),
                .product(name: "BlockchainNamespace", package: "BlockchainNamespace"),
                .product(name: "FeatureWithdrawalLocksUI", package: "FeatureWithdrawalLocks"),
                .product(name: "FeatureCardPaymentDomain", package: "FeatureCardPayment")
            ],
            resources: [
                .copy("PlatformUIKitAssets.xcassets")
            ]
        ),
        .target(
            name: "PlatformKitMock",
            dependencies: [
                .target(name: "PlatformKit")
            ]
        ),
        .target(
            name: "PlatformUIKitMock",
            dependencies: [
                .target(name: "PlatformUIKit"),
                .product(name: "AnalyticsKitMock", package: "Analytics"),
                .product(name: "ToolKitMock", package: "Tool")
            ]
        ),
        .testTarget(
            name: "PlatformKitTests",
            dependencies: [
                .target(name: "PlatformKit"),
                .target(name: "PlatformKitMock"),
                .product(name: "MoneyKitMock", package: "Money"),
                .product(name: "FeatureAuthenticationMock", package: "FeatureAuthentication"),
                .product(name: "NetworkKitMock", package: "Network"),
                .product(name: "ToolKitMock", package: "Tool"),
                .product(name: "TestKit", package: "Test"),
                .product(name: "RxBlocking", package: "RxSwift"),
                .product(name: "RxTest", package: "RxSwift")
            ],
            resources: [
                .copy("Fixtures/wallet-data.json")
            ]
        ),
        .testTarget(
            name: "PlatformUIKitTests",
            dependencies: [
                .target(name: "PlatformKitMock"),
                .target(name: "PlatformUIKit"),
                .target(name: "PlatformUIKitMock"),
                .product(name: "TestKit", package: "Test"),
                .product(name: "RxBlocking", package: "RxSwift"),
                .product(name: "RxTest", package: "RxSwift")
            ]
        )
    ]
)
