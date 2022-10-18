// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// Model representing a `Sparkline`.
/// For more information, see [Wikipedia.](https://en.wikipedia.org/wiki/Sparkline)
public struct SparklineCalculator {

    /// The attributes of the `Sparkline`
    let attributes: SparklineAttributes

    var size: CGSize {
        attributes.size
    }

    var lineWidth: CGFloat {
        attributes.lineWidth
    }

    public init(attributes: SparklineAttributes) {
        self.attributes = attributes
    }

    /// `[Decimal]` are the `y-values` represented in the line graph.
    /// Note that the `x-values` are derived from the `size` provided.
    /// It is assumed that the values are provided in order.
    public func sparkline(with values: [Decimal]) -> UIBezierPath {
        let line = UIBezierPath()
        let points = normalizedPoints(from: values)

        line.move(to: points.first ?? .zero)
        line.lineCapStyle = .round
        line.lineJoinStyle = .round
        line.lineWidth = attributes.lineWidth

        if points.count == 2 {
            guard let last = points.last else { return line }
            line.addLine(to: last)
            return line
        }

        points.forEach {
            line.addLine(to: $0)
        }

        return line
    }

    /// The normalized dataset. The plotted points are normalized
    /// so that despite what may be very small deltas across the values
    /// the chart shows the overall pattern and fills the size provided.
    private func normalizedPoints(from values: [Decimal]) -> [CGPoint] {
        let interval = attributes.width / CGFloat(values.count - 1)
        let min = values.min
        let max = values.max
        return values.enumerated().map {
            let index = $0
            let value = CGFloat($1.doubleValue)
            let ratio = (value - min) == 0 ? 0 : (value - min) / (max - min)
            let x = interval * CGFloat(index)
            let y = attributes.height * (1 - ratio)
            return .init(x: x, y: y)
        }
    }
}

extension [Decimal] {

    /// The largest value in the dataset.
    fileprivate var max: CGFloat {
        CGFloat(self.max()?.doubleValue ?? 0)
    }

    /// The smallest value in the dataset.
    fileprivate var min: CGFloat {
        CGFloat(self.min()?.doubleValue ?? 0)
    }
}
