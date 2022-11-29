// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Embrace
import FeatureAddressSearchDomain
import FeatureAddressSearchUI
import FeatureAuthenticationDomain
import FeatureCardIssuingDomain
import FeatureCardIssuingUI
import FeatureCoinData
import FeatureCoinDomain
import FeatureKYCDomain
import FeatureKYCUI
import FeatureOpenBankingUI
import FeatureQRCodeScannerDomain
import FeatureSettingsUI
import FeatureTransactionUI
import ObservabilityKit
import PlatformKit
import PlatformUIKit
import ToolKit
import UIKit

extension DependencyContainer {

    public static var featureAppUI = module {

        single { BlurVisualEffectHandler() as BlurVisualEffectHandlerAPI }

        single { () -> BackgroundAppHandlerAPI in
            let timer = BackgroundTaskTimer(
                invalidBackgroundTaskIdentifier: BackgroundTaskIdentifier(
                    identifier: UIBackgroundTaskIdentifier.invalid
                )
            )
            return BackgroundAppHandler(backgroundTaskTimer: timer)
        }

        // MARK: Open Banking

        factory { () -> FeatureOpenBankingUI.FiatCurrencyFormatter in
            FiatCurrencyFormatter()
        }

        factory { () -> FeatureOpenBankingUI.CryptoCurrencyFormatter in
            CryptoCurrencyFormatter()
        }

        factory { LaunchOpenBankingFlow() as StartOpenBanking }

        // MARK: QR Code Scanner

        factory { () -> CryptoTargetQRCodeParserAdapter in
            QRCodeScannerAdapter(
                qrCodeScannerRouter: DIKit.resolve(),
                payloadFactory: DIKit.resolve(),
                topMostViewControllerProvider: DIKit.resolve(),
                navigationRouter: DIKit.resolve()
            )
        }

        factory { () -> QRCodeScannerLinkerAPI in
            QRCodeScannerAdapter(
                qrCodeScannerRouter: DIKit.resolve(),
                payloadFactory: DIKit.resolve(),
                topMostViewControllerProvider: DIKit.resolve(),
                navigationRouter: DIKit.resolve()
            )
        }

        single {
            DeepLinkCoordinator(
                app: DIKit.resolve(),
                coincore: DIKit.resolve(),
                exchangeProvider: DIKit.resolve(),
                kycRouter: DIKit.resolve(),
                payloadFactory: DIKit.resolve(),
                topMostViewControllerProvider: DIKit.resolve(),
                transactionsRouter: DIKit.resolve(),
                analyticsRecording: DIKit.resolve(),
                walletConnectService: { DIKit.resolve() },
                onboardingRouter: DIKit.resolve()
            )
        }

        factory {
            CardIssuingAdapter(
                cardIssuingBuilder: DIKit.resolve(),
                nabuUserService: DIKit.resolve()
            ) as FeatureSettingsUI.CardIssuingViewControllerAPI
        }

        factory {
            CardIssuingTopUpRouter(
                coincore: DIKit.resolve(),
                transactionsRouter: DIKit.resolve()
            ) as TopUpRouterAPI
        }

        factory(tag: CardIssuingTag.residentialAddress) {
            CardIssuingAddressSearchRouter(
                addressSearchRouterRouter: DIKit.resolve(tag: CardIssuingTag.residentialAddress)
            ) as FeatureCardIssuingUI.AddressSearchRouterAPI
        }

        factory(tag: CardIssuingTag.shippingAddress) {
            CardIssuingAddressSearchRouter(
                addressSearchRouterRouter: DIKit.resolve(tag: CardIssuingTag.shippingAddress)
            ) as FeatureCardIssuingUI.AddressSearchRouterAPI
        }

        factory(tag: CardIssuingTag.residentialAddress) {
            AddressSearchRouter(
                topMostViewControllerProvider: DIKit.resolve(),
                addressService: DIKit.resolve(tag: CardIssuingTag.residentialAddress)
            ) as FeatureAddressSearchDomain.AddressSearchRouterAPI
        }

        factory(tag: CardIssuingTag.shippingAddress) {
            AddressSearchRouter(
                topMostViewControllerProvider: DIKit.resolve(),
                addressService: DIKit.resolve(tag: CardIssuingTag.shippingAddress)
            ) as FeatureAddressSearchDomain.AddressSearchRouterAPI
        }

        factory(tag: CardIssuingTag.residentialAddress) {
            AddressService(
                repository: DIKit.resolve(tag: CardIssuingTag.residentialAddress)
            ) as FeatureAddressSearchDomain.AddressServiceAPI
        }

        factory(tag: CardIssuingTag.shippingAddress) {
            AddressService(
                repository: DIKit.resolve(tag: CardIssuingTag.shippingAddress)
            ) as FeatureAddressSearchDomain.AddressServiceAPI
        }

        factory { () -> AddressSearchFlowPresenterAPI in
            AddressSearchFlowPresenter(
                addressSearchRouterRouter: DIKit.resolve()
            ) as AddressSearchFlowPresenterAPI
        }

        factory {
            AddressSearchRouter(
                topMostViewControllerProvider: DIKit.resolve(),
                addressService: DIKit.resolve()
            ) as FeatureAddressSearchDomain.AddressSearchRouterAPI
        }

        factory {
            AddressKYCService() as FeatureAddressSearchDomain.AddressServiceAPI
        }

        single { () -> AssetInformationRepositoryAPI in
            AssetInformationRepository(
                AssetInformationClient(
                    networkAdapter: DIKit.resolve(),
                    requestBuilder: DIKit.resolve()
                )
            )
        }

        factory { () -> ObservabilityServiceAPI in
            ObservabilityService(
                client: Embrace.sharedInstance()
            )
        }

        factory {
            CardIssuingAccountPickerAdapter(
                cardService: DIKit.resolve(),
                coinCore: DIKit.resolve(),
                fiatCurrencyService: DIKit.resolve(),
                nabuUserService: DIKit.resolve()
            ) as AccountProviderAPI
        }

        factory { UpdateSettingsClient(DIKit.resolve()) as UpdateSettingsClientAPI }
    }
}
