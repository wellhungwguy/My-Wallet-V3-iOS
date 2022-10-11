import BlockchainNamespace
import Combine
import FeatureCardPaymentDomain
import PassKit
import PlatformKit
import ToolKit

final class ApplePayAdapter: ApplePayEligibleServiceAPI {

    private let app: AppProtocol
    private let eligibleMethodsClient: PaymentEligibleMethodsClientAPI
    private let fiatCurrencyService: FiatCurrencyServiceAPI
    private let featureFlagsService: FeatureFlagsServiceAPI
    private let tiersService: KYCTiersServiceAPI

    init(
        app: AppProtocol,
        fiatCurrencyService: FiatCurrencyServiceAPI,
        featureFlagsService: FeatureFlagsServiceAPI,
        eligibleMethodsClient: PaymentEligibleMethodsClientAPI,
        tiersService: KYCTiersServiceAPI
    ) {
        self.app = app
        self.fiatCurrencyService = fiatCurrencyService
        self.featureFlagsService = featureFlagsService
        self.tiersService = tiersService
        self.eligibleMethodsClient = eligibleMethodsClient
    }

    func isFrontendEnabled() -> AnyPublisher<Bool, Never> {
        guard PKPaymentAuthorizationController.canMakePayments() else {
            return .just(false)
        }

        return app.publisher(for: blockchain.app.configuration.apple.pay.is.enabled, as: Bool.self)
            .prefix(1)
            .replaceError(with: false)
            .eraseToAnyPublisher()
    }

    func isBackendEnabled() -> AnyPublisher<Bool, Never> {
        fiatCurrencyService.tradingCurrency
            .zip(isFrontendEnabled())
            .flatMap { [tiersService, eligibleMethodsClient] fiatCurrency, enabled -> AnyPublisher<Bool, Never> in
                guard enabled else {
                    return .just(false)
                }

                return tiersService
                    .fetchTiers()
                    .flatMap { tiersResult -> AnyPublisher<(KYC.UserTiers, SimplifiedDueDiligenceResponse), Never> in
                        tiersService
                            .simplifiedDueDiligenceEligibility(for: tiersResult.latestApprovedTier)
                            .map { sddEligibiliy in (tiersResult, sddEligibiliy) }
                            .eraseToAnyPublisher()
                    }
                    .flatMap { tiersResult, sddEligility -> AnyPublisher<Bool, Never> in
                        eligibleMethodsClient.eligiblePaymentMethods(
                            for: fiatCurrency.code,
                            currentTier: tiersResult.latestApprovedTier,
                            sddEligibleTier: tiersResult.canRequestSDDPaymentMethods(
                                isSDDEligible: sddEligility.eligible
                            ) ? sddEligility.tier : nil
                        )
                        .map { methods in
                            methods.contains { method in
                                method.applePayEligible
                            }
                        }
                        .replaceError(with: false)
                        .eraseToAnyPublisher()
                    }
                    .replaceError(with: false)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
