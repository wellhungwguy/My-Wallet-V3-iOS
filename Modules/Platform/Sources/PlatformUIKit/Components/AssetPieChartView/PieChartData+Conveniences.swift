// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Charts

extension PieChartData {
    public convenience init(with values: [AssetPieChart.Value.Interaction]) {
        let values = values.map { AssetPieChart.Value.Presentation(value: $0) }
        let entries = values.map { PieChartDataEntry(value: $0.percentage.doubleValue, label: $0.debugDescription) }
        let set = PieChartDataSet(entries: entries, label: nil)
        set.drawIconsEnabled = false
        set.drawValuesEnabled = false
        set.selectionShift = 0
        set.sliceSpace = 3
        set.colors = values.map(\.color)
        self.init(dataSet: set)
    }

    /// Returns an `empty` grayish pie chart data
    public static var empty: PieChartData {
        let set = PieChartDataSet(entries: [PieChartDataEntry(value: 100)], label: nil)
        set.drawIconsEnabled = false
        set.drawValuesEnabled = false
        set.selectionShift = 0
        set.colors = [.clear]
        return PieChartData(dataSet: set)
    }
}
