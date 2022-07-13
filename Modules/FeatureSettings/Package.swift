// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "FeatureSettings",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "FeatureSettings",
            targets: [
                "FeatureSettingsData",
                "FeatureSettingsDomain",
                "FeatureSettingsUI"
            ]
        ),
        .library(
            name: "FeatureSettingsData",
            targets: ["FeatureSettingsData"]
        ),
        .library(
            name: "FeatureSettingsDomain",
            targets: ["FeatureSettingsDomain"]
        ),
        .library(
            name: "FeatureSettingsUI",
            targets: ["FeatureSettingsUI"]
        ),
        .library(
            name: "FeatureSettingsDomainMock",
            targets: ["FeatureSettingsDomainMock"]
        )
    ],
    dependencies: [
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
        .package(path: "../CommonCrypto"),
        .package(path: "../FeatureAuthentication"),
        .package(path: "../FeatureKYC"),
        .package(path: "../Network"),
        .package(path: "../Platform"),
        .package(path: "../Tool"),
        .package(path: "../WalletPayload"),
        .package(path: "../ComposableArchitectureExtensions"),
        .package(path: "../FeatureCardPayment"),
        .package(path: "../FeatureNotificationPreferences"),
        .package(path: "../FeatureReferral"),
        .package(path: "../FeatureUserDeletion")
    ],
    targets: [
        .target(
            name: "FeatureSettingsDomain",
            dependencies: [
                .product(name: "CommonCryptoKit", package: "CommonCrypto"),
                .product(name: "FeatureAuthenticationDomain", package: "FeatureAuthentication"),
                .product(name: "FeatureKYCDomain", package: "FeatureKYC"),
                .product(name: "NetworkKit", package: "Network"),
                .product(name: "PlatformKit", package: "Platform"),
                .product(name: "PlatformUIKit", package: "Platform"),
                .product(name: "RxCocoa", package: "RxSwift"),
                .product(name: "RxRelay", package: "RxSwift"),
                .product(name: "RxSwift", package: "RxSwift"),
                .product(name: "ToolKit", package: "Tool"),
                .product(name: "WalletPayloadKit", package: "WalletPayload")
            ]
        ),
        .target(
            name: "FeatureSettingsData",
            dependencies: [
                .target(name: "FeatureSettingsDomain"),
                .product(name: "NetworkKit", package: "Network"),
                .product(name: "DIKit", package: "DIKit")
            ]
        ),
        .target(
            name: "FeatureSettingsUI",
            dependencies: [
                .target(name: "FeatureSettingsDomain"),
                .product(name: "FeatureKYCUI", package: "FeatureKYC"),
                .product(name: "ComposableNavigation", package: "ComposableArchitectureExtensions"),
                .product(name: "FeatureCardPaymentUI", package: "FeatureCardPayment"),
                .product(name: "FeatureCardPaymentDomain", package: "FeatureCardPayment"),
                .product(name: "FeatureNotificationPreferencesUI", package: "FeatureNotificationPreferences"),
                .product(name: "FeatureReferralUI", package: "FeatureReferral"),
                .product(name: "FeatureUserDeletionData", package: "FeatureUserDeletion"),
                .product(name: "FeatureUserDeletionDomain", package: "FeatureUserDeletion"),
                .product(name: "FeatureUserDeletionUI", package: "FeatureUserDeletion")
            ]
        ),
        .target(
            name: "FeatureSettingsDomainMock",
            dependencies: [
                .target(name: "FeatureSettingsDomain")
            ]
        ),
        .testTarget(
            name: "FeatureSettingsDomainTests",
            dependencies: [
                .target(name: "FeatureSettingsDomain")
            ]
        ),
        .testTarget(
            name: "FeatureSettingsUITests",
            dependencies: [
                .target(name: "FeatureSettingsUI")
            ]
        )
    ]
)
