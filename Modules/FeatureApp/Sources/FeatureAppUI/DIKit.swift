// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Embrace
import FeatureAddressSearchDomain
import FeatureAddressSearchUI
import FeatureAuthenticationDomain
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

private enum AddressSearchTag: String {
    case cardOrder
    case kyc
}

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

        factory {
            CardIssuingAddressSearchRouter(
                addressSearchRouterRouter: DIKit.resolve(tag: AddressSearchTag.cardOrder)
            ) as FeatureCardIssuingUI.AddressSearchRouterAPI
        }

        factory(tag: AddressSearchTag.cardOrder) {
            AddressSearchRouter(
                topMostViewControllerProvider: DIKit.resolve(),
                addressService: DIKit.resolve(tag: AddressSearchTag.cardOrder)
            ) as FeatureAddressSearchDomain.AddressSearchRouterAPI
        }

        factory(tag: AddressSearchTag.cardOrder) {
            AddressService(
                repository: DIKit.resolve()
            ) as FeatureAddressSearchDomain.AddressServiceAPI
        }

        factory { () -> AddressSearchFlowPresenterAPI in
            AddressSearchFlowPresenter(
                addressSearchRouterRouter: DIKit.resolve(tag: AddressSearchTag.kyc)
            ) as AddressSearchFlowPresenterAPI
        }

        factory(tag: AddressSearchTag.kyc) {
            AddressSearchRouter(
                topMostViewControllerProvider: DIKit.resolve(),
                addressService: DIKit.resolve(tag: AddressSearchTag.kyc)
            ) as FeatureAddressSearchDomain.AddressSearchRouterAPI
        }

        factory(tag: AddressSearchTag.kyc) {
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
