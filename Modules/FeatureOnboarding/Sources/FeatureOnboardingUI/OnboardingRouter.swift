// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import CombineSchedulers
import DIKit
import Errors
import SwiftUI
import ToolKit
import UIKit

public protocol KYCRouterAPI {
    func presentEmailVerification(from presenter: UIViewController) -> AnyPublisher<OnboardingResult, Never>
    func presentKYCUpgradePrompt(from presenter: UIViewController) -> AnyPublisher<OnboardingResult, Never>
    func presentTier1KYCIfNeeded(from presenter: UIViewController) -> AnyPublisher<OnboardingResult, Never>
}

public protocol TransactionsRouterAPI {
    func presentBuyFlow(from presenter: UIViewController) -> AnyPublisher<OnboardingResult, Never>
    func navigateToBuyCryptoFlow(from presenter: UIViewController)
    func navigateToReceiveCryptoFlow(from presenter: UIViewController)
}

public final class OnboardingRouter: OnboardingRouterAPI {

    // MARK: - Properties

    let app: AppProtocol
    let kycRouter: KYCRouterAPI
    let transactionsRouter: TransactionsRouterAPI
    let featureFlagsService: FeatureFlagsServiceAPI
    let mainQueue: AnySchedulerOf<DispatchQueue>

    // MARK: - Init

    public init(
        app: AppProtocol = resolve(),
        kycRouter: KYCRouterAPI = resolve(),
        transactionsRouter: TransactionsRouterAPI = resolve(),
        featureFlagsService: FeatureFlagsServiceAPI = resolve(),
        mainQueue: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self.app = app
        self.kycRouter = kycRouter
        self.transactionsRouter = transactionsRouter
        self.featureFlagsService = featureFlagsService
        self.mainQueue = mainQueue
    }

    // MARK: - Onboarding Routing

    public func presentPostSignUpOnboarding(from presenter: UIViewController) -> AnyPublisher<OnboardingResult, Never> {
        // Step 1: present email verification
        presentEmailVerification(from: presenter)
            .flatMap { [weak self] _ -> AnyPublisher<OnboardingResult, Never> in
                guard let self = self else { return .just(.abandoned) }
                return Task<OnboardingResult, Error>.Publisher {
                    if try await self.app.get(blockchain.user.is.cowboy.fan) {
                        return try await self.presentCowboyPromotion(from: presenter)
                    } else {
                        return await self.presentUITour(from: presenter).await().or(.abandoned)
                    }
                }
                .replaceError(with: .abandoned)
                .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    public func presentPostSignInOnboarding(from presenter: UIViewController) -> AnyPublisher<OnboardingResult, Never> {
        kycRouter.presentKYCUpgradePrompt(from: presenter)
    }

    public func presentRequiredCryptoBalanceView(
        from presenter: UIViewController
    ) -> AnyPublisher<OnboardingResult, Never> {
        let subject = PassthroughSubject<OnboardingResult, Never>()
        let view = CryptoBalanceRequiredView(
            store: .init(
                initialState: (),
                reducer: CryptoBalanceRequired.reducer,
                environment: CryptoBalanceRequired.Environment(
                    close: {
                        presenter.dismiss(animated: true) {
                            subject.send(.abandoned)
                            subject.send(completion: .finished)
                        }
                    },
                    presentBuyFlow: { [transactionsRouter] in
                        presenter.dismiss(animated: true) {
                            transactionsRouter.navigateToBuyCryptoFlow(from: presenter)
                        }
                    },
                    presentRequestCryptoFlow: { [transactionsRouter] in
                        presenter.dismiss(animated: true) {
                            transactionsRouter.navigateToReceiveCryptoFlow(from: presenter)
                        }
                    }
                )
            )
        )
        presenter.present(view)
        return subject.eraseToAnyPublisher()
    }

    // MARK: - Helper Methods

    private func presentUITour(from presenter: UIViewController) -> AnyPublisher<OnboardingResult, Never> {
        let subject = PassthroughSubject<OnboardingResult, Never>()
        let view = UITourView(
            close: {
                subject.send(.abandoned)
                subject.send(completion: .finished)
            },
            completion: {
                subject.send(.completed)
                subject.send(completion: .finished)
            }
        )
        let hostingController = UIHostingController(rootView: view)
        hostingController.modalTransitionStyle = .crossDissolve
        hostingController.modalPresentationStyle = .overFullScreen
        presenter.present(hostingController, animated: true, completion: nil)
        return subject
            .flatMap { [transactionsRouter] result -> AnyPublisher<OnboardingResult, Never> in
                guard case .completed = result else {
                    return .just(.abandoned)
                }
                return Deferred {
                    Future { completion in
                        presenter.dismiss(animated: true) {
                            completion(.success(()))
                        }
                    }
                }
                .flatMap {
                    transactionsRouter.presentBuyFlow(from: presenter)
                }
                .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    private func presentEmailVerification(from presenter: UIViewController) -> AnyPublisher<OnboardingResult, Never> {
        featureFlagsService.isEnabled(.showEmailVerificationInOnboarding)
            .receive(on: mainQueue)
            .flatMap { [kycRouter] shouldShowEmailVerification -> AnyPublisher<OnboardingResult, Never> in
                guard shouldShowEmailVerification else {
                    return .just(.completed)
                }
                return kycRouter.presentEmailVerification(from: presenter)
            }
            .eraseToAnyPublisher()
    }

    @MainActor
    private func presentTier1KYCIfNeeded(from presenter: UIViewController) async -> OnboardingResult {
        await kycRouter.presentTier1KYCIfNeeded(from: presenter)
            .await()
            .or(.abandoned)
    }

    private func presentCowboyPromotion(from presenter: UIViewController) async throws -> OnboardingResult {
        let verifyEmail = await present(
            promotion: blockchain.ux.onboarding.promotion.cowboys.verify.email,
            from: presenter
        )
        guard case .completed = verifyEmail else { return .abandoned }
        guard case .completed = await presentTier1KYCIfNeeded(from: presenter) else { return .abandoned }
        return await present(
            promotion: blockchain.ux.onboarding.promotion.cowboys.raffle,
            from: presenter
        )
    }

    @discardableResult
    private func present(
        promotion: I_blockchain_ux_onboarding_type_promotion,
        from presenter: UIViewController
    ) async -> OnboardingResult {
        do {
            let view = try await PromotionView(promotion, ux: app.get(promotion.story))
                .app(app)
            await MainActor.run {
                presenter.present(UIHostingController(rootView: view), animated: true)
            }
            guard let event = try await app.on(
                promotion.then.launch.url,
                promotion.then.close
            ).stream().next() else {
                return .abandoned
            }
            switch event.tag {
            case blockchain.ui.type.action.then.launch.url:
                return .completed
            default:
                return .abandoned
            }
        } catch {
            return .abandoned
        }
    }
}
