// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Errors
import FeatureTransactionDomain
import MoneyKit
import PlatformKit

final class CustodialTransferRepository: CustodialTransferRepositoryAPI {

    // MARK: - Properties

    private let client: CustodialTransferClientAPI

    // MARK: - Setup

    init(client: CustodialTransferClientAPI = resolve()) {
        self.client = client
    }

    // MARK: - CustodialTransferServiceAPI

    func feesAndLimitsForInterest() -> AnyPublisher<CustodialTransferFee, NabuNetworkError> {
        client
            .custodialTransferFeesForProduct(.savings)
            .map { response in
                CustodialTransferFee(
                    fee: response.fees,
                    minimumAmount: response.minAmounts
                )
            }
            .eraseToAnyPublisher()
    }

    func transfer(
        moneyValue: MoneyValue,
        destination: String,
        memo: String?
    ) -> AnyPublisher<CustodialWithdrawalIdentifier, NabuNetworkError> {
        client
            .send(
                transferRequest: CustodialTransferRequest(
                    address: destinationAddress(with: destination, memo: memo),
                    moneyValue: moneyValue
                )
            )
            .map(\.identifier)
            .eraseToAnyPublisher()
    }

    func fees() -> AnyPublisher<CustodialTransferFee, NabuNetworkError> {
        client
            .custodialTransferFees()
            .map { response in
                CustodialTransferFee(
                    fee: response.fees,
                    minimumAmount: response.minAmounts
                )
            }
            .eraseToAnyPublisher()
    }

    private func destinationAddress(with destination: String, memo: String?) -> String {
        guard let memo, !memo.isEmpty else {
            return destination
        }
        return destination + ":" + memo
    }
}
