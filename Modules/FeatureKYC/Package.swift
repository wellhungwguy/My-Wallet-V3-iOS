// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "FeatureKYC",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
        .watchOS(.v7),
        .tvOS(.v14)
    ],
    products: [
        .library(
            name: "FeatureKYC",
            targets: ["FeatureKYCDomain", "FeatureKYCUI"]
        ),
        .library(
            name: "FeatureKYCDomain",
            targets: ["FeatureKYCDomain"]
        ),
        .library(
            name: "FeatureKYCUI",
            targets: ["FeatureKYCUI"]
        ),
        .library(
            name: "FeatureKYCMock",
            targets: ["FeatureKYCDomainMock", "FeatureKYCUIMock"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/pointfreeco/swift-composable-architecture",
            from: "0.38.3"
        ),
        .package(
            url: "https://github.com/attaswift/BigInt.git",
            from: "5.2.1"
        ),
        .package(
            url: "https://github.com/jackpooleybc/DIKit.git",
            branch: "safe-property-wrappers"
        ),
        .package(
            url: "https://github.com/ReactiveX/RxSwift.git",
            from: "6.2.0"
        ),
        .package(
            url: "https://github.com/Veriff/veriff-ios-spm.git",
            exact: "4.17.0"
        ),
        .package(path: "../Analytics"),
        .package(path: "../FeatureAuthentication"),
        .package(path: "../FeatureForm"),
        .package(path: "../Localization"),
        .package(path: "../Network"),
        .package(path: "../Platform"),
        .package(path: "../Test"),
        .package(path: "../Tool"),
        .package(path: "../UIComponents"),
        .package(path: "../BlockchainComponentLibrary"),
        .package(path: "../ComposableArchitectureExtensions")
    ],
    targets: [
        .target(
            name: "FeatureKYCDomain",
            dependencies: [
                .product(name: "DIKit", package: "DIKit"),
                .product(name: "FeatureFormDomain", package: "FeatureForm"),
                .product(name: "PlatformKit", package: "Platform"),
                .product(name: "RxSwift", package: "RxSwift"),
                .product(name: "ToolKit", package: "Tool"),
                .product(name: "NetworkKit", package: "Network")
            ]
        ),
        .target(
            name: "FeatureKYCUI",
            dependencies: [
                .target(name: "FeatureKYCDomain"),
                .product(name: "FeatureFormDomain", package: "FeatureForm"),
                .product(name: "FeatureFormUI", package: "FeatureForm"),
                .product(name: "AnalyticsKit", package: "Analytics"),
                .product(name: "BigInt", package: "BigInt"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "ComposableNavigation", package: "ComposableArchitectureExtensions"),
                .product(name: "DIKit", package: "DIKit"),
                .product(name: "FeatureAuthenticationDomain", package: "FeatureAuthentication"),
                .product(name: "Localization", package: "Localization"),
                .product(name: "NetworkKit", package: "Network"),
                .product(name: "PlatformKit", package: "Platform"),
                .product(name: "PlatformUIKit", package: "Platform"),
                .product(name: "RxSwift", package: "RxSwift"),
                .product(name: "ToolKit", package: "Tool"),
                .product(name: "BlockchainComponentLibrary", package: "BlockchainComponentLibrary"),
                .product(name: "UIComponents", package: "UIComponents"),
                .product(name: "Veriff", package: "veriff-ios-spm")
            ],
            resources: [
                .copy("Media.xcassets")
            ]
        ),
        .target(
            name: "FeatureKYCDomainMock",
            dependencies: [
                .target(name: "FeatureKYCDomain"),
                .product(name: "PlatformKit", package: "Platform"),
                .product(name: "PlatformUIKit", package: "Platform"),
                .product(name: "RxSwift", package: "RxSwift")
            ]
        ),
        .target(
            name: "FeatureKYCUIMock",
            dependencies: [
                .target(name: "FeatureKYCDomain"),
                .target(name: "FeatureKYCUI"),
                .product(name: "PlatformKit", package: "Platform")
            ]
        ),
        .testTarget(
            name: "FeatureKYCDomainTests",
            dependencies: [
                .target(name: "FeatureKYCDomain"),
                .product(name: "PlatformKitMock", package: "Platform"),
                .product(name: "TestKit", package: "Test")
            ]
        ),
        .testTarget(
            name: "FeatureKYCUITests",
            dependencies: [
                .target(name: "FeatureKYCDomainMock"),
                .target(name: "FeatureKYCUI"),
                .target(name: "FeatureKYCUIMock"),
                .product(name: "AnalyticsKitMock", package: "Analytics"),
                .product(name: "FeatureAuthenticationMock", package: "FeatureAuthentication"),
                .product(name: "PlatformKitMock", package: "Platform"),
                .product(name: "PlatformUIKitMock", package: "Platform"),
                .product(name: "ToolKitMock", package: "Tool"),
                .product(name: "TestKit", package: "Test")
            ],
            exclude: [
                "_New_KYC/Limits/__Snapshots__",
                "_New_KYC/EmailVerification/__Snapshots__"
            ]
        )
    ]
)
