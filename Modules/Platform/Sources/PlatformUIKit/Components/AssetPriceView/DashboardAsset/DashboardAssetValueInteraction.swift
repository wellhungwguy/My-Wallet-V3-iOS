// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import Localization
import MoneyKit
import PlatformKit

extension DashboardAsset.Value.Interaction {

    public struct AssetPrice {

        /// Time unit. Can be further customized in future
        /// Each value currently refers to 1 unit
        public enum Time {

            private typealias LocalizedString = LocalizationConstants.TimeUnit

            case hours(Int)
            case days(Int)
            case weeks(Int)
            case months(Int)
            case years(Int)
            case timestamp(Date)
            case all

            var string: String {
                switch self {
                case .hours(let number):
                    let time = number > 1 ? LocalizedString.Plural.hours : LocalizedString.Singular.hour
                    return "\(number) \(time)"
                case .days(let number):
                    let time = number > 1 ? LocalizedString.Plural.days : LocalizedString.Singular.day
                    return "\(number) \(time)"
                case .weeks(let number):
                    let time = number > 1 ? LocalizedString.Plural.weeks : LocalizedString.Singular.week
                    return "\(number) \(time)"
                case .months(let number):
                    let time = number > 1 ? LocalizedString.Plural.months : LocalizedString.Singular.month
                    return "\(number) \(time)"
                case .years(let number):
                    switch number > 1 {
                    case true:
                        return LocalizedString.Plural.allTime
                    case false:
                        return "\(number) \(LocalizedString.Singular.year)"
                    }
                case .timestamp(let date):
                    return DateFormatter.medium.string(from: date)
                case .all:
                    return LocalizedString.Plural.allTime
                }
            }
        }

        /// The asset price in fiat.
        public let currentPrice: MoneyValue

        public struct HistoricalPrice {
            /// The `Time` for the given `AssetPrice`
            public let time: Time

            /// Percentage of change since a certain time
            public let changePercentage: Double

            /// The change in fiat value
            public let priceChange: MoneyValue

            public init?(time: Time, currentPrice: MoneyValue, previousPrice: MoneyValue) {
                self.time = time
                guard let priceChange = try? currentPrice - previousPrice else {
                    return nil
                }
                self.priceChange = priceChange
                // Zero or negative previousBalance shouldn't be possible but
                // it is handled in any case, in a way that does not throw.
                if currentPrice.isPositive, previousPrice.isPositive {
                    let changePercentage: Decimal = (try? priceChange.percentage(in: previousPrice)) ?? .zero
                    self.changePercentage = changePercentage.doubleValue
                } else {
                    self.changePercentage = 0
                }
            }

            init(
                time: Time,
                changePercentage: Double,
                priceChange: MoneyValue
            ) {
                self.time = time
                self.changePercentage = changePercentage
                self.priceChange = priceChange
            }
        }

        /// Percentage of change since a certain time
        public let historicalPrice: HistoricalPrice?

        public init(
            currentPrice: MoneyValue,
            time: Time?,
            changePercentage: Double?,
            priceChange: MoneyValue?
        ) {
            guard let time,
                  let changePercentage,
                  let priceChange
            else {
                self.init(
                    currentPrice: currentPrice,
                    historicalPrice: nil,
                    marketCap: nil
                )
                return
            }
            self.init(
                currentPrice: currentPrice,
                historicalPrice: HistoricalPrice(
                    time: time,
                    changePercentage: changePercentage,
                    priceChange: priceChange
                ),
                marketCap: nil
            )
        }

        /// Current market capitalization.
        public let marketCap: Double?

        public init(
            currentPrice: MoneyValue,
            historicalPrice: HistoricalPrice?,
            marketCap: Double?
        ) {
            self.currentPrice = currentPrice
            self.historicalPrice = historicalPrice
            self.marketCap = marketCap
        }
    }
}
