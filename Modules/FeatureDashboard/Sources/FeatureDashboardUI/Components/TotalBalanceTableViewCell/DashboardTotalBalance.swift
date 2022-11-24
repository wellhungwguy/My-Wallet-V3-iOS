// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Charts
import ComposableArchitectureExtensions
import PlatformKit
import PlatformUIKit

enum DashboardTotalBalance {
    enum State {
        typealias Interaction = LoadingState<Value.Interaction>
        typealias Presentation = LoadingState<Value.Presentation>
    }

    enum Value {

        /// The interaction value of dashboard asset
        struct Interaction {

            /// The chart data
            let chart: [AssetPieChart.Value.Interaction]

            /// The asset / account price data
            let price: DashboardAsset.Value.Interaction.AssetPrice
        }

        /// The presentation value of a dashboard asset
        struct Presentation {

            /// The chart data
            let chart: PieChartData
            let price: DashboardAsset.Value.Presentation.AssetPrice

            init(with value: Interaction) {
                self.chart = PieChartData(with: value.chart)
                self.price = .init(with: value.price, descriptors: .balance)
            }
        }
    }
}
