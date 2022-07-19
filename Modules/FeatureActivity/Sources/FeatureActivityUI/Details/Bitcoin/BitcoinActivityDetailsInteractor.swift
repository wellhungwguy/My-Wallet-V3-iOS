// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BitcoinKit
import Combine
import DIKit
import MoneyKit
import PlatformKit
import RxSwift
import ToolKit

enum BitcoinActivityDetailsError: Error {
    case unableToRetrieveNote
    case unableToSaveNote
}

final class BitcoinActivityDetailsInteractor {

    private let fiatCurrencySettings: FiatCurrencySettingsServiceAPI
    private let priceService: PriceServiceAPI
    private let detailsService: AnyActivityItemEventDetailsFetcher<BitcoinActivityItemEventDetails>
    private let bitcoinTxNoteProvider: BitcoinTxNoteProvider
    private let bitcoinTxNoteUpdater: BitcoinTxNoteUpdater

    init(
        bitcoinTxNoteProvider: @escaping BitcoinTxNoteProvider = resolve(),
        bitcoinTxNoteUpdater: @escaping BitcoinTxNoteUpdater = resolve(),
        fiatCurrencySettings: FiatCurrencySettingsServiceAPI = resolve(),
        priceService: PriceServiceAPI = resolve(),
        detailsService: AnyActivityItemEventDetailsFetcher<BitcoinActivityItemEventDetails> = resolve()
    ) {
        self.bitcoinTxNoteProvider = bitcoinTxNoteProvider
        self.bitcoinTxNoteUpdater = bitcoinTxNoteUpdater
        self.detailsService = detailsService
        self.fiatCurrencySettings = fiatCurrencySettings
        self.priceService = priceService
    }

    private func note(for identifier: String) -> AnyPublisher<String?, BitcoinActivityDetailsError> {
        bitcoinTxNoteProvider(identifier)
            .mapError { _ in BitcoinActivityDetailsError.unableToRetrieveNote }
            .eraseToAnyPublisher()
    }

    func updateNote(
        for identifier: String,
        to note: String?
    ) -> AnyPublisher<EmptyValue, BitcoinActivityDetailsError> {
        bitcoinTxNoteUpdater(identifier, note)
            .mapError { _ in BitcoinActivityDetailsError.unableToRetrieveNote }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    private func price(at date: Date) -> Single<PriceQuoteAtTime> {
        fiatCurrencySettings
            .displayCurrency
            .asSingle()
            .flatMap(weak: self) { (self, fiatCurrency) in
                self.price(at: date, in: fiatCurrency)
            }
    }

    private func price(at date: Date, in fiatCurrency: FiatCurrency) -> Single<PriceQuoteAtTime> {
        priceService.price(
            of: CurrencyType.crypto(.bitcoin),
            in: fiatCurrency,
            at: .time(date)
        )
        .asSingle()
    }

    func details(identifier: String, createdAt: Date) -> Observable<BitcoinActivityDetailsViewModel> {
        let transaction = detailsService
            .details(for: identifier, cryptoCurrency: .bitcoin)
        let note = note(for: identifier)
            .asSingle()
            .catchAndReturn(nil)
        let price = price(at: createdAt)
            .optional()
            .catchAndReturn(nil)

        return Observable
            .combineLatest(
                transaction,
                price.asObservable(),
                note.asObservable()
            )
            .map { BitcoinActivityDetailsViewModel(details: $0, price: $1?.moneyValue.fiatValue, note: $2) }
    }
}
