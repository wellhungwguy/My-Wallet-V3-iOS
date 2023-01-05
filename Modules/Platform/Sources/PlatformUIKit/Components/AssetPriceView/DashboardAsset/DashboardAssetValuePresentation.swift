// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import PlatformKit

extension DashboardAsset.Value.Presentation {

    /// The presentation model for `AssetPriceView`
    public struct AssetPrice: CustomDebugStringConvertible {

        private typealias AccessibilityId = Accessibility.Identifier.Dashboard.AssetCell

        /// Descriptors that allows customized content and style
        public struct Descriptors {

            /// Options to display content
            struct ContentOptions: OptionSet {
                let rawValue: Int

                init(rawValue: Int) {
                    self.rawValue = rawValue
                }

                /// Includes fiat price change
                static let fiat = ContentOptions(rawValue: 1 << 0)

                /// Includes percentage price change
                static let percentage = ContentOptions(rawValue: 2 << 0)
            }

            let contentOptions: ContentOptions
            let priceFont: UIFont
            let changeFont: UIFont
            let accessibilityIdSuffix: String
        }

        // MARK: - Properties

        /// The price of the asset
        let price: LabelContent

        /// The change
        let change: NSAttributedString

        let changeAccessibility: Accessibility

        public var debugDescription: String {
            price.text + " " + change.string
        }

        // MARK: - Setup

        public init(with value: DashboardAsset.Value.Interaction.AssetPrice, descriptors: Descriptors) {
            let fiatPrice = value.currentPrice.toDisplayString(includeSymbol: true)
            self.changeAccessibility = .id("\(AccessibilityId.changeLabelFormat)\(descriptors.accessibilityIdSuffix)")
            self.price = LabelContent(
                text: fiatPrice,
                font: descriptors.priceFont,
                color: .dashboardAssetTitle,
                accessibility: .id("\(AccessibilityId.marketFiatBalanceLabelFormat)\(descriptors.accessibilityIdSuffix)")
            )

            self.change = value.historicalPrice
                .flatMap { historicalPrice in
                    Self.changeAttributeString(with: historicalPrice, descriptors: descriptors)
                }
                ?? NSAttributedString()
        }

        private static func changeAttributeString(
            with historicalPrice: DashboardAsset.Value.Interaction.AssetPrice.HistoricalPrice,
            descriptors: Descriptors
        ) -> NSAttributedString {
            let fiatTintColor: UIColor
            var deltaTintColor: UIColor
            let sign: String
            if historicalPrice.priceChange.isPositive {
                sign = "+"
                fiatTintColor = .positivePrice
            } else if historicalPrice.priceChange.isNegative {
                sign = ""
                fiatTintColor = .negativePrice
            } else {
                sign = ""
                fiatTintColor = .mutedText
            }
            deltaTintColor = historicalPrice.changePercentage > 0 ? .positivePrice : .negativePrice
            deltaTintColor = historicalPrice.changePercentage.isZero ? .mutedText : deltaTintColor

            let fiatChange: NSAttributedString
            if descriptors.contentOptions.contains(.fiat) {
                let fiat = historicalPrice.priceChange.toDisplayString(includeSymbol: true)
                let suffix = descriptors.contentOptions.contains(.percentage) ? " " : ""
                fiatChange = NSAttributedString(
                    LabelContent(
                        text: "\(sign)\(fiat)\(suffix)",
                        font: descriptors.changeFont,
                        color: fiatTintColor
                    )
                )
            } else {
                fiatChange = NSAttributedString()
            }

            let percentageChange: NSAttributedString
            if descriptors.contentOptions.contains(.percentage) {
                let prefix: String
                let suffix: String
                if descriptors.contentOptions.contains(.fiat) {
                    prefix = "("
                    suffix = ")"
                } else {
                    prefix = ""
                    suffix = ""
                }
                let percentage = historicalPrice.changePercentage * 100
                let percentageString = percentage.string(with: 2)
                percentageChange = NSAttributedString(
                    LabelContent(
                        text: "\(prefix)\(percentageString)%\(suffix)",
                        font: descriptors.changeFont,
                        color: deltaTintColor
                    )
                )
            } else {
                percentageChange = NSAttributedString()
            }

            let period = NSAttributedString(
                LabelContent(
                    text: historicalPrice.time.string,
                    font: descriptors.changeFont,
                    color: .mutedText
                )
            )
            return fiatChange + percentageChange + period
        }
    }
}

extension DashboardAsset.Value.Presentation.AssetPrice.Descriptors {
    /// Returns a descriptor for dashboard total balance
    public static var balance: DashboardAsset.Value.Presentation.AssetPrice.Descriptors {
        .init(
            contentOptions: [.fiat, .percentage],
            priceFont: .main(.semibold, 24.0),
            changeFont: .main(.medium, 14.0),
            accessibilityIdSuffix: Accessibility.Identifier.Dashboard.TotalBalanceCell.valueLabelSuffix
        )
    }

    /// Returns a descriptor for dashboard asset price
    public static func assetPrice(
        accessibilityIdSuffix: String,
        priceFontSize: CGFloat = 16.0,
        changeFontSize: CGFloat = 14.0
    ) -> DashboardAsset.Value.Presentation.AssetPrice.Descriptors {
        .init(
            contentOptions: [.percentage],
            priceFont: .main(.semibold, priceFontSize),
            changeFont: .main(.medium, changeFontSize),
            accessibilityIdSuffix: accessibilityIdSuffix
        )
    }

    /// Returns a descriptor for widget asset price
    public static func widget(accessibilityIdSuffix: String) -> DashboardAsset.Value.Presentation.AssetPrice.Descriptors {
        .init(
            contentOptions: [.fiat],
            priceFont: .systemFont(ofSize: 16.0, weight: .semibold),
            changeFont: .systemFont(ofSize: 12.0, weight: .semibold),
            accessibilityIdSuffix: accessibilityIdSuffix
        )
    }
}
