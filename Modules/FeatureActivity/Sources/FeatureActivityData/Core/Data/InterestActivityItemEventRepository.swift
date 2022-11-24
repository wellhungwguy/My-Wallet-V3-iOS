// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import MoneyKit
import PlatformKit
import ToolKit

final class InterestActivityItemEventRepository: InterestActivityItemEventRepositoryAPI {

    // MARK: - Private Properties

    private let client: InterestActivityItemEventClientAPI
    private let cachedValue: CachedValueNew<
        CryptoCurrency,
        [InterestActivityItemEvent],
        InterestActivityRepositoryError
    >

    // MARK: - Init

    init(client: InterestActivityItemEventClientAPI = resolve()) {
        self.client = client
        let cache = InMemoryCache<CryptoCurrency, [InterestActivityItemEvent]>(
            configuration: .onLoginLogoutTransaction(),
            refreshControl: PeriodicCacheRefreshControl(refreshInterval: 90)
        )
        .eraseToAnyCache()
        self.cachedValue = CachedValueNew(
            cache: cache,
            fetch: { key in
                client
                    .fetchInterestActivityItemEventsForCryptoCurrency(
                        key
                    )
                    .map(\.items)
                    .mapError(InterestActivityRepositoryError.networkError)
                    .map { items -> [InterestActivityItemEvent] in
                        items.map { response in
                            InterestActivityItemEvent(
                                response,
                                currency: key
                            )
                        }
                    }
                    .eraseToAnyPublisher()
            }
        )
    }

    // MARK: - InterestActivityItemEventRepositoryAPI

    func fetchInterestActivityItemEventsForCryptoCurrency(
        _ cryptoCurrency: CryptoCurrency
    ) -> AnyPublisher<[InterestActivityItemEvent], InterestActivityRepositoryError> {
        cachedValue.get(key: cryptoCurrency)
    }
}

extension InterestActivityItemEvent {
    init(
        _ response: InterestActivityItemEventResponse,
        currency: CryptoCurrency
    ) {
        self.init(
            value: .create(minor: response.amountMinor, currency: currency) ?? .zero(currency: currency),
            cryptoCurrency: currency,
            identifier: response.id,
            insertedAt: DateFormatter.iso8601Format.date(from: response.insertedAt) ?? Date.distantPast,
            confirmations: response.extraAttributes?.confirmations ?? 0,
            accountRef: response.extraAttributes?.beneficiary?.accountRef ?? "",
            recipientAddress: response.extraAttributes?.address ?? "",
            isInternalTransfer: response.extraAttributes?.isInternalTransfer ?? false,
            state: InterestActivityItemEvent.interestStateFromResponseState(response.state),
            type: InterestActivityItemEvent.transactionTypeFromString(response.type)
        )
    }

    private static func interestStateFromResponseState(
        _ state: InterestActivityItemEventResponse.State
    ) -> InterestActivityItemEventState {
        switch state {
        case .cleared:
            return .cleared
        case .failed:
            return .failed
        case .rejected:
            return .rejected
        case .processing:
            return .processing
        case .complete,
             .created:
            return .complete
        case .pending,
             .fraudReview:
            return .pending
        case .manualReview:
            return .manualReview
        case .refunded:
            return .refunded
        case .unknown:
            return .unknown
        }
    }

    private static func transactionTypeFromString(
        _ value: String
    ) -> InterestTransactionType {
        switch value {
        case "DEPOSIT":
            return .transfer
        case "WITHDRAWAL":
            return .withdraw
        case "INTEREST_OUTGOING":
            return .interestEarned
        default:
            Logger.shared.error("Unhandled InterestTransactionType: \(value)")
            return .unknown
        }
    }
}
