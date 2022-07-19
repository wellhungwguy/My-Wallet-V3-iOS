// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import FeatureKYCDomain
import FeatureKYCUI
import FeatureOnboardingUI
import FeatureSettingsUI
import PlatformKit
import PlatformUIKit
import RxSwift
import ToolKit
import UIComponentsKit
import UIKit

public final class KYCAdapter {

    // MARK: - Properties

    private let router: FeatureKYCUI.Routing

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init

    public init(router: FeatureKYCUI.Routing = resolve()) {
        self.router = router
    }

    // MARK: - Public Interface

    public func presentEmailVerificationAndKYCIfNeeded(
        from presenter: UIViewController,
        requireEmailVerification: Bool,
        requiredTier: KYC.Tier
    ) -> AnyPublisher<FeatureKYCUI.FlowResult, FeatureKYCUI.RouterError> {
        router
            .presentEmailVerificationAndKYCIfNeeded(
                from: presenter,
                requireEmailVerification: requireEmailVerification,
                requiredTier: requiredTier
            )
            .eraseToAnyPublisher()
    }

    public func presentEmailVerificationIfNeeded(
        from presenter: UIViewController
    ) -> AnyPublisher<FeatureKYCUI.FlowResult, FeatureKYCUI.RouterError> {
        router
            .presentEmailVerificationIfNeeded(from: presenter)
            .eraseToAnyPublisher()
    }

    public func presentKYCIfNeeded(
        from presenter: UIViewController,
        requiredTier: KYC.Tier
    ) -> AnyPublisher<FeatureKYCUI.FlowResult, FeatureKYCUI.RouterError> {
        router
            .presentKYCIfNeeded(from: presenter, requiredTier: requiredTier)
            .eraseToAnyPublisher()
    }
}

extension KYCAdapter {

    public func presentKYCIfNeeded(
        from presenter: UIViewController,
        requireEmailVerification: Bool,
        requiredTier: KYC.Tier,
        completion: @escaping (FeatureKYCUI.FlowResult) -> Void
    ) {
        presentEmailVerificationAndKYCIfNeeded(
            from: presenter,
            requireEmailVerification: requireEmailVerification,
            requiredTier: requiredTier
        )
        .sink(receiveValue: completion)
        .store(in: &cancellables)
    }
}

// MARK: - PlatformUIKit.KYCRouting

extension KYCRouterError {

    public init(_ error: FeatureKYCUI.RouterError) {
        switch error {
        case .emailVerificationFailed:
            self = .emailVerificationFailed
        case .kycVerificationFailed:
            self = .kycVerificationFailed
        case .kycStepFailed:
            self = .kycStepFailed
        }
    }
}

extension KYCRoutingResult {

    public init(_ result: FeatureKYCUI.FlowResult) {
        switch result {
        case .abandoned:
            self = .abandoned
        case .completed:
            self = .completed
        }
    }
}

extension KYCAdapter: PlatformUIKit.KYCRouting {

    public func presentEmailVerificationAndKYCIfNeeded(
        from presenter: UIViewController,
        requiredTier: KYC.Tier
    ) -> AnyPublisher<KYCRoutingResult, KYCRouterError> {
        presentEmailVerificationAndKYCIfNeeded(
            from: presenter,
            requireEmailVerification: false,
            requiredTier: requiredTier
        )
        .mapError(KYCRouterError.init)
        .map(KYCRoutingResult.init)
        .eraseToAnyPublisher()
    }

    public func presentEmailVerificationIfNeeded(
        from presenter: UIViewController
    ) -> AnyPublisher<KYCRoutingResult, KYCRouterError> {
        presentEmailVerificationIfNeeded(from: presenter)
            .mapError(KYCRouterError.init)
            .map(KYCRoutingResult.init)
            .eraseToAnyPublisher()
    }

    public func presentKYCIfNeeded(
        from presenter: UIViewController,
        requiredTier: KYC.Tier
    ) -> AnyPublisher<KYCRoutingResult, KYCRouterError> {
        presentKYCIfNeeded(from: presenter, requiredTier: requiredTier)
            .mapError(KYCRouterError.init)
            .map(KYCRoutingResult.init)
            .eraseToAnyPublisher()
    }

    public func presentKYCUpgradeFlow(
        from presenter: UIViewController
    ) -> AnyPublisher<KYCRoutingResult, Never> {
        router.presentPromptToUnlockMoreTrading(from: presenter)
            .map(KYCRoutingResult.init)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    public func presentKYCUpgradeFlowIfNeeded(
        from presenter: UIViewController,
        requiredTier: KYC.Tier
    ) -> AnyPublisher<KYCRoutingResult, KYCRouterError> {
        router.presentPromptToUnlockMoreTradingIfNeeded(from: presenter, requiredTier: requiredTier)
            .mapError(KYCRouterError.init)
            .map(KYCRoutingResult.init)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

// MARK: - FeatureOnboardingUI.KYCRouterAPI

extension OnboardingResult {

    public init(_ result: FeatureKYCUI.FlowResult) {
        switch result {
        case .abandoned:
            self = .abandoned
        case .completed:
            self = .completed
        }
    }
}

extension KYCAdapter: FeatureOnboardingUI.KYCRouterAPI {

    public func presentEmailVerification(from presenter: UIViewController) -> AnyPublisher<OnboardingResult, Never> {
        router.presentEmailVerificationIfNeeded(from: presenter)
            .map(OnboardingResult.init)
            .replaceError(with: OnboardingResult.completed)
            .eraseToAnyPublisher()
    }

    public func presentKYCUpgradePrompt(from presenter: UIViewController) -> AnyPublisher<OnboardingResult, Never> {
        router.presentNoticeToUnlockMoreTradingIfNeeded(from: presenter, requiredTier: .tier2)
            .map(OnboardingResult.init)
            .replaceError(with: OnboardingResult.completed)
            .eraseToAnyPublisher()
    }
}

extension KYCAdapter: FeatureSettingsUI.KYCRouterAPI {

    public func presentLimitsOverview(from presenter: UIViewController) {
        router.presentLimitsOverview(from: presenter)
    }
}
