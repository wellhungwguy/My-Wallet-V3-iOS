// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Charts
import ComposableArchitectureExtensions
import MoneyKit
import PlatformKit

/// Any util / data related to the pie chart presentation / interaction layers
public enum AssetPieChart {

    public enum State {
        public typealias Interaction = LoadingState<[AssetPieChart.Value.Interaction]>
        public typealias Presentation = LoadingState<PieChartData>
    }

    // MARK: - Value namespace

    public enum Value {

        /// Value for the interaction level
        public struct Interaction: Equatable {

            /// The asset type
            let asset: CurrencyType

            /// Percentage that the asset takes off the total
            let percentage: Decimal

            init(asset: CurrencyType, percentage: Decimal) {
                self.asset = asset
                self.percentage = percentage
            }
        }

        /// A presentation value
        public struct Presentation: CustomDebugStringConvertible {

            public let debugDescription: String

            /// The color of the asset
            let color: UIColor

            /// The percentage of the asset from the total of 100%
            let percentage: Decimal

            public init(value: Interaction) {
                self.debugDescription = value.asset.displayCode
                self.color = value.asset.brandUIColor
                self.percentage = value.percentage
            }
        }
    }
}
