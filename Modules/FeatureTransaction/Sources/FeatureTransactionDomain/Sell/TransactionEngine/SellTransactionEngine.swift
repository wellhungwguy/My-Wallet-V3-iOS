// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import MoneyKit
import PlatformKit
import RxSwift

protocol SellTransactionEngine: TransactionEngine {

    var orderDirection: OrderDirection { get }
    var quotesEngine: QuotesEngineAPI { get }
    var transactionLimitsService: TransactionLimitsServiceAPI { get }
    var orderQuoteRepository: OrderQuoteRepositoryAPI { get }
    var orderCreationRepository: OrderCreationRepositoryAPI { get }
}

extension SellTransactionEngine {

    var target: FiatAccount {
        transactionTarget as! FiatAccount
    }

    var sourceAsset: CryptoCurrency { sourceCryptoCurrency }
    var targetAsset: FiatCurrency { target.fiatCurrency }

    var pair: OrderPair {
        OrderPair(
            sourceCurrencyType: sourceAsset.currencyType,
            destinationCurrencyType: target.fiatCurrency.currencyType
        )
    }

    // MARK: - TransactionEngine

    func validateUpdateAmount(_ amount: MoneyValue) -> Single<MoneyValue> {
        sourceExchangeRatePair.map { exchangeRate -> MoneyValue in
            if amount.isFiat {
                return amount.convert(using: exchangeRate.inverseQuote.quote)
            } else {
                return amount
            }
        }
    }

    var fiatExchangeRatePairs: Observable<TransactionMoneyValuePairs> {
        sourceExchangeRatePair
            .map { source -> TransactionMoneyValuePairs in
                TransactionMoneyValuePairs(
                    source: source,
                    destination: source.inverseExchangeRate
                )
            }
            .asObservable()
    }

    var sourceExchangeRatePair: Single<MoneyValuePair> {
        transactionExchangeRatePair
            .take(1)
            .asSingle()
    }

    var transactionExchangeRatePair: Observable<MoneyValuePair> {
        quotesEngine.quotePublisher
            .asObservable()
            .map { [target] pricedQuote -> MoneyValue in
                MoneyValue(amount: pricedQuote.price, currency: target.currencyType)
            }
            .map { [sourceAsset] rate -> MoneyValuePair in
                MoneyValuePair(base: .one(currency: sourceAsset), exchangeRate: rate)
            }
            .asObservable()
    }

    func updateLimits(
        pendingTransaction: PendingTransaction,
        pricedQuote: PricedQuote
    ) -> Single<PendingTransaction> {
        let limitsPublisher = transactionLimitsService.fetchLimits(
            source: LimitsAccount(
                currency: sourceAsset.currencyType,
                accountType: orderDirection.isFromCustodial ? .custodial : .nonCustodial
            ),
            destination: LimitsAccount(
                currency: targetAsset.currencyType,
                accountType: orderDirection.isToCustodial ? .custodial : .nonCustodial
            ),
            product: .sell(orderDirection)
        )
        return limitsPublisher
            .asSingle()
            .map { transactionLimits -> PendingTransaction in
                var pendingTransaction = pendingTransaction
                pendingTransaction.limits = try transactionLimits.update(with: pricedQuote)
                return pendingTransaction
            }
    }

    func clearConfirmations(pendingTransaction oldValue: PendingTransaction) -> PendingTransaction {
        var pendingTransaction = oldValue
        let quoteSubscription = pendingTransaction.quoteSubscription
        quoteSubscription?.dispose()
        pendingTransaction.engineState.mutate { $0[.quoteSubscription] = nil }
        return pendingTransaction.update(confirmations: [])
    }

    func createOrder(pendingTransaction: PendingTransaction) -> Single<SellOrder> {
        quotesEngine.quotePublisher
            .asSingle()
            .flatMap { [weak self] quote -> Single<SellOrder> in
                guard let self = self else { return .never() }
                return self.orderCreationRepository.createOrder(
                    direction: self.orderDirection,
                    quoteIdentifier: quote.identifier,
                    volume: pendingTransaction.amount,
                    ccy: self.target.currencyType.code
                )
                .asSingle()
            }
            .do(onSuccess: { [weak self] _ in
                self?.disposeQuotesFetching(pendingTransaction: pendingTransaction)
            })
    }

    private func disposeQuotesFetching(pendingTransaction: PendingTransaction) {
        var pendingTransaction = pendingTransaction
        pendingTransaction.quoteSubscription?.dispose()
        pendingTransaction.engineState.mutate { $0[.quoteSubscription] = nil }
        quotesEngine.stop()
    }

    func doValidateAll(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        defaultDoValidateAll(pendingTransaction: pendingTransaction)
    }

    func defaultDoValidateAll(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        validateAmount(pendingTransaction: pendingTransaction)
    }

    func startConfirmationsUpdate(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        startQuotesFetchingIfNotStarted(pendingTransaction: pendingTransaction)
    }

    private func startQuotesFetchingIfNotStarted(
        pendingTransaction oldValue: PendingTransaction
    ) -> Single<PendingTransaction> {
        guard oldValue.quoteSubscription == nil else {
            return .just(oldValue)
        }
        var pendingTransaction = oldValue
        pendingTransaction.engineState.mutate { $0[.quoteSubscription] = startQuotesFetching() }
        return .just(pendingTransaction)
    }

    private func startQuotesFetching() -> Disposable {
        quotesEngine
            .quotePublisher
            .asObservable()
            .flatMap { [weak self] _ -> Observable<Void> in
                self?.askForRefreshConfirmation(true) ?? .empty()
            }
            .subscribe()
    }

    func doRefreshConfirmations(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        doBuildConfirmations(pendingTransaction: pendingTransaction)
    }

    func stop(pendingTransaction: PendingTransaction) {
        disposeQuotesFetching(pendingTransaction: pendingTransaction)
    }

    // MARK: - Exchange Rates

    public func onChainFeeToSourceRate(
        pendingTransaction: PendingTransaction,
        tradingCurrency: FiatCurrency
    ) -> AnyPublisher<MoneyValue, PriceServiceError> {
        // The price endpoint doesn't support crypto -> crypto rates, so we need to be careful here.
        currencyConversionService.conversionRate(
            from: pendingTransaction.feeAmount.currency,
            to: target.currencyType
        )
        .zip(
            sourceToFiatTradingCurrencyRate(
                pendingTransaction: pendingTransaction,
                tradingCurrency: target.fiatCurrency
            )
        )
        .map { [sourceAsset] feeToFiatRate, sourceToFiatRate in
            feeToFiatRate.convert(usingInverse: sourceToFiatRate, currency: sourceAsset.currencyType)
        }
        .eraseToAnyPublisher()
    }

    func amountToSourceRate(
        pendingTransaction: PendingTransaction,
        tradingCurrency: FiatCurrency
    ) -> AnyPublisher<MoneyValue, PriceServiceError> {
        sourceExchangeRatePair.asPublisher()
            .compactMap { ratePair in
                let exchangeRate: MoneyValue?
                if pendingTransaction.amount.isFiat {
                    exchangeRate = ratePair.inverseQuote.quote
                } else {
                    exchangeRate = .one(currency: pendingTransaction.amount.currency)
                }
                return exchangeRate
            }
            .mapError { _ in PriceServiceError.missingPrice(pendingTransaction.missingPriceDescription) }
            .eraseToAnyPublisher()
    }

    func fiatTradingCurrencyToSourceRate(
        pendingTransaction: PendingTransaction,
        tradingCurrency: FiatCurrency
    ) -> AnyPublisher<MoneyValue, PriceServiceError> {
        sourceExchangeRatePair.asPublisher()
            .compactMap { ratePair in
                ratePair.inverseQuote.quote
            }
            .mapError { _ in PriceServiceError.missingPrice(pendingTransaction.missingPriceDescription) }
            .eraseToAnyPublisher()
    }

    func sourceToFiatTradingCurrencyRate(
        pendingTransaction: PendingTransaction,
        tradingCurrency: FiatCurrency
    ) -> AnyPublisher<MoneyValue, PriceServiceError> {
        sourceExchangeRatePair.asPublisher()
            .map(\.quote)
            .compactMap { $0 }
            .mapError { _ in PriceServiceError.missingPrice(pendingTransaction.missingPriceDescription) }
            .eraseToAnyPublisher()
    }

    func destinationToFiatTradingCurrencyRate(
        pendingTransaction: PendingTransaction,
        tradingCurrency: FiatCurrency
    ) -> AnyPublisher<MoneyValue, PriceServiceError> {
        Just(.one(currency: target.fiatCurrency))
            .setFailureType(to: PriceServiceError.self)
            .eraseToAnyPublisher()
    }

    func sourceToDestinationTradingCurrencyRate(
        pendingTransaction: PendingTransaction,
        tradingCurrency: FiatCurrency
    ) -> AnyPublisher<MoneyValue, PriceServiceError> {
        sourceToFiatTradingCurrencyRate(
            pendingTransaction: pendingTransaction,
            tradingCurrency: tradingCurrency
        )
    }
}

extension TransactionLimits {

    func update(with quote: PricedQuote) throws -> TransactionLimits {
        let minimum = try calculateMinimumLimit(for: quote)
        return TransactionLimits(
            currencyType: minimum.currencyType,
            minimum: minimum,
            maximum: maximum,
            maximumDaily: maximumDaily,
            maximumAnnual: maximumAnnual,
            effectiveLimit: effectiveLimit,
            suggestedUpgrade: suggestedUpgrade
        )
    }

    private func calculateMinimumLimit(for quote: PricedQuote) throws -> MoneyValue {
        let destinationCurrency = quote.networkFee.currencyType
        let price = MoneyValue(amount: quote.price, currency: destinationCurrency)
        let totalFees = (try? quote.networkFee + quote.staticFee) ?? MoneyValue.zero(currency: destinationCurrency)
        let convertedFees: MoneyValue = totalFees.convert(usingInverse: price, currency: currencyType)
        let minimum = minimum ?? .zero(currency: destinationCurrency)
        return (try? minimum + convertedFees) ?? MoneyValue.zero(currency: destinationCurrency)
    }
}

extension PendingTransaction {

    fileprivate var quoteSubscription: Disposable? {
        engineState.value[.quoteSubscription] as? Disposable
    }
}
