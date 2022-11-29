// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

// TODO: Move this to a more appropriate module perhaps, it may be useful for other views as well.

/// A linear animated gradient view modifier
struct AnimatableLinearGradient: ViewModifier, Animatable {
    let from: [Color]
    let to: [Color]
    let startPoint: UnitPoint
    let endPoint: UnitPoint
    var percent: CGFloat = 0.0

    var animatableData: CGFloat {
        get { percent }
        set { percent = newValue }
    }

    func body(content: Content) -> some View {
        var gradientColors: [Color] = []
        for i in 0..<from.count {
            let fromColor = UIColor(from[i])
            let toColor = UIColor(to[i])
            gradientColors.append(colorMixing(from: fromColor, to: toColor, percent: percent))
        }
        return LinearGradient(
            gradient: Gradient(colors: gradientColors),
            startPoint: startPoint,
            endPoint: endPoint
        )
    }

    /// A simple color mixer
    private func colorMixing(
        from: UIColor,
        to: UIColor,
        percent: CGFloat
    ) -> Color {
        guard let firstColor = from.cgColor.components else {
            return Color(from)
        }
        guard let secondColor = to.cgColor.components else {
            return Color(from)
        }

        let red = (firstColor[0] + (secondColor[0] - firstColor[0]) * percent)
        let green = (firstColor[1] + (secondColor[1] - firstColor[1]) * percent)
        let blue = (firstColor[2] + (secondColor[2] - firstColor[2]) * percent)

        return Color(red: Double(red), green: Double(green), blue: Double(blue))
    }
}

extension View {

    /// Provides an animated LinearGradient
    /// - Parameters:
    ///   - fromColors: The colors that the animation will begin from
    ///   - toColors: The colors that the animation will end to
    ///   - startPoint: A `UnitPoint` that indicates the start position of the gradient
    ///   - endPoint: A `UnitPoint` that indicates the end position of the gradient
    ///   - percent: A `CGFloat` for the percentage of the color blending (animated).
    ///   At `0.0` value the `fromColors` are displayed at `1.0` the `toColors`
    /// - Returns: some View
    func animatableLinearGradient(
        fromColors: [Color],
        toColors: [Color],
        startPoint: UnitPoint,
        endPoint: UnitPoint,
        percent: CGFloat
    ) -> some View {
        modifier(
            AnimatableLinearGradient(
                from: fromColors,
                to: toColors,
                startPoint: startPoint,
                endPoint: endPoint,
                percent: percent
            )
        )
    }
}
