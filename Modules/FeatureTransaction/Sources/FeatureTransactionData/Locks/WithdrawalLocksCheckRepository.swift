// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureTransactionDomain

final class WithdrawalLocksCheckRepository: WithdrawalLocksCheckRepositoryAPI {

    // MARK: - Properties

    private let client: WithdrawalLocksCheckClientAPI

    // MARK: - Setup

    init(client: WithdrawalLocksCheckClientAPI) {
        self.client = client
    }

    func withdrawalLocksCheck(
        paymentMethod: String?,
        currencyCode: String?
    ) -> AnyPublisher<WithdrawalLocksCheck, Never> {
        guard let paymentMethod, let currencyCode else {
            return .just(.init(lockDays: 0))
        }
        return client.fetchWithdrawalLocksCheck(paymentMethod: paymentMethod, currencyCode: currencyCode)
            .replaceError(with: .init(rule: nil))
            .map {
                let lockTime = Double($0.rule?.lockTime ?? 0)
                let secondsInDay = Double(86400)
                let lockDays = lockTime / secondsInDay
                return WithdrawalLocksCheck(lockDays: Int(lockDays.rounded(.up)))
            }
            .eraseToAnyPublisher()
    }
}
