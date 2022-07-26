// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import Combine
import DIKit
import Errors
import MoneyKit
import PlatformKit

struct PricedQuote {
    let identifier: String
    let price: BigInt
    let networkFee: MoneyValue
    let staticFee: MoneyValue
    let sampleDepositAddress: String
    let expirationDate: Date
}

protocol QuotesEngineAPI {
    var quotePublisher: AnyPublisher<PricedQuote, Never> { get }

    func stop()
    func update(amount: BigInt)
    func startPollingRate(
        direction: OrderDirection,
        pair: OrderPair
    )
}

final class QuotesEngine: QuotesEngineAPI {

    // MARK: - Constants

    private enum Constants {
        static let retryCount = 3
        static let quoteRefreshThreshold: TimeInterval = 10
        static let maxQuoteRefresh: TimeInterval = 31
    }

    // MARK: - Private

    private let repository: OrderQuoteRepositoryAPI
    private let timer: (TimeInterval) -> AnyPublisher<Void, Never>

    private let stopSubject = PassthroughSubject<Void, Never>()
    private let amountSubject = CurrentValueSubject<BigInt, Never>(.zero)

    private var quoteSubject = CurrentValueSubject<PricedQuote?, Never>(nil)
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init

    init(
        repository: OrderQuoteRepositoryAPI = resolve(),
        timer: @escaping (TimeInterval) -> AnyPublisher<Void, Never> = { every in
            Timer.publish(every: every, on: .main, in: .default)
                .autoconnect()
                .mapToVoid()
                .eraseToAnyPublisher()
        }
    ) {
        self.repository = repository
        self.timer = timer
    }

    // MARK: - Public

    var quotePublisher: AnyPublisher<PricedQuote, Never> {
        quoteSubject.compactMap { $0 }.eraseToAnyPublisher()
    }

    func stop() {
        stopSubject.send(())
        quoteSubject.send(nil)
        cancellables.removeAll()
    }

    func update(amount: BigInt) {
        amountSubject.send(amount)
    }

    func startPollingRate(
        direction: OrderDirection,
        pair: OrderPair
    ) {
        stop()
        let quotePublisher = repository
            .fetchQuote(
                direction: direction,
                sourceCurrencyType: pair.sourceCurrencyType,
                destinationCurrencyType: pair.destinationCurrencyType
            )
            .retry(Constants.retryCount)
            .eraseToAnyPublisher()

        let expirationQuotePublisher = quotePublisher
            .flatMap { [timer, stopSubject] quote -> AnyPublisher<OrderQuotePayload, NabuNetworkError> in
                let quoteExpirationRefresh = quote.expiresAt.timeIntervalSince(Date()) - Constants.quoteRefreshThreshold
                return timer(min(quoteExpirationRefresh, Constants.maxQuoteRefresh))
                    .flatMap { _ in quotePublisher }
                    .prepend(quote)
                    .prefix(untilOutputFrom: stopSubject)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()

        Publishers.CombineLatest(
            expirationQuotePublisher.ignoreFailure(),
            amountSubject
        )
        .map { quote, amount -> PricedQuote in
            let interpolator = PricesInterpolator(prices: quote.quote.priceTiers)
            let quoteExpirationRefresh = quote.expiresAt.timeIntervalSince(Date()) - Constants.quoteRefreshThreshold
            return PricedQuote(
                identifier: quote.identifier,
                price: interpolator.rate(amount: amount),
                networkFee: quote.networkFee,
                staticFee: quote.staticFee,
                sampleDepositAddress: quote.sampleDepositAddress,
                expirationDate: Date(timeIntervalSinceNow: min(quoteExpirationRefresh, Constants.maxQuoteRefresh))
            )
        }
        .eraseToAnyPublisher()
        .sink(receiveValue: quoteSubject.send(_:))
        .store(in: &cancellables)
    }
}
