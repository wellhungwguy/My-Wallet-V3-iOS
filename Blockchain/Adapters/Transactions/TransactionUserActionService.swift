// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureAppDomain
import FeatureProductsDomain
import FeatureTransactionDomain
import FeatureTransactionUI
import PlatformKit

final class TransactionUserActionService: UserActionServiceAPI {

    private let userService: UserAdapterAPI
    private(set) var latestUserState: UserState?
    private var cancellables = Set<AnyCancellable>()

    init(userService: UserAdapterAPI) {
        self.userService = userService
        registerForUserStateUpdates()
    }

    func canPresentTransactionFlow(
        toPerform action: TransactionFlowAction
    ) -> AnyPublisher<UserActionServiceResult, Never> {
        userService.userState
            .first()
            .map { userStateResult -> UserActionServiceResult in
                let productId = action.productId
                if case .success(let userState) = userStateResult {
                    guard userState.canStartTransactionFlow(for: productId) else {
                        let upgradeTier: KYC.Tier?
                        if let requiredTier = userState.requiredTierToUse(productId) {
                            upgradeTier = KYC.Tier(rawValue: requiredTier)
                        } else {
                            upgradeTier = nil
                        }
                        return .cannotPerform(upgradeTier: upgradeTier)
                    }
                }
                return .canPerform
            }
            .eraseToAnyPublisher()
    }

    private func registerForUserStateUpdates() {
        userService.userState
            .sink { [weak self] userStateResult in
                guard case .success(let userState) = userStateResult else {
                    return
                }
                self?.latestUserState = userState
            }
            .store(in: &cancellables)
    }
}

extension TransactionUserActionService: TransactionRestrictionsProviderAPI {

    func maximumNumbersOfTransactions(for action: AssetAction) -> Int? {
        // Ignore Tier 0 users
        guard latestUserState?.kycStatus != .unverified else {
            return nil
        }

        guard let product = latestUserState?.product(id: action.productId) else {
            return nil
        }

        return product.maxOrdersCap ?? product.maxOrdersLeft
    }
}

extension AssetAction {

    var productId: ProductIdentifier? {
        let productId: ProductIdentifier?
        switch self {
        case .buy:
            productId = .buy
        case .sell:
            productId = .sell
        case .swap:
            productId = .swap
        case .deposit:
            productId = .depositFiat
        case .withdraw:
            productId = .withdrawFiat
        case .receive:
            productId = .depositCrypto
        case .send:
            productId = .withdrawCrypto
        default:
            productId = nil
        }
        return productId
    }
}

extension TransactionFlowAction {

    var productId: ProductIdentifier? {
        let productId: ProductIdentifier?
        switch self {
        case .buy:
            productId = .buy
        case .sell:
            productId = .sell
        case .swap:
            productId = .swap
        case .deposit:
            productId = .depositFiat
        case .withdraw:
            productId = .withdrawFiat
        case .receive:
            productId = .depositCrypto
        case .send:
            productId = .withdrawCrypto
        default:
            productId = nil
        }
        return productId
    }
}

extension UserState {

    fileprivate func canStartTransactionFlow(for productId: ProductIdentifier?) -> Bool {
        // For first-time users, let them go through the buy flow.
        if productId == .buy, kycStatus == .unverified {
            return true
        }
        // For everyone else, check the actual product.
        guard let product = product(id: productId) else {
            // Let users use products we don't have information for
            return true
        }
        return product.enabled
    }
}
