// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import Foundation
import MoneyKit

public class HistoricalPriceService {

    private let base: CryptoCurrency
    private let displayFiatCurrency: AnyPublisher<FiatCurrency, Never>
    private let historicalPriceRepository: HistoricalPriceRepositoryAPI

    public init(
        base: CryptoCurrency,
        displayFiatCurrency: AnyPublisher<FiatCurrency, Never>,
        historicalPriceRepository: HistoricalPriceRepositoryAPI
    ) {
        self.base = base
        self.displayFiatCurrency = displayFiatCurrency
        self.historicalPriceRepository = historicalPriceRepository
    }

    public func fetch(series: Series, relativeTo: Date) -> AnyPublisher<GraphData, NetworkError> {
        displayFiatCurrency.flatMap { [base, historicalPriceRepository] fiatCurrency in
            historicalPriceRepository.fetchGraphData(
                base: base,
                quote: fiatCurrency,
                series: series,
                relativeTo: relativeTo
            )
            .map { data in
                GraphData(
                    series: data.series.filter(\.price.isNormal),
                    base: data.base,
                    quote: data.quote
                )
            }
        }
        .eraseToAnyPublisher()
    }
}

// MARK: - Preview Helper

extension HistoricalPriceService {

    public static var preview: HistoricalPriceService {
        .init(
            base: .bitcoin,
            displayFiatCurrency: .empty(),
            historicalPriceRepository: PreviewHistoricalPriceRepository(.just(.preview))
        )
    }

    public static var previewEmpty: HistoricalPriceService {
        .init(
            base: .bitcoin,
            displayFiatCurrency: .empty(),
            historicalPriceRepository: PreviewHistoricalPriceRepository()
        )
    }
}
