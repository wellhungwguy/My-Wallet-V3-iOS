// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import Extensions
import SwiftUI

public struct IndeterminateProgressStyle: ProgressViewStyle {

    public var stroke: Color
    public var background: Color

    public var lineWidth: Length
    public var duration: TimeInterval
    public var indeterminate: Bool
    public var lineCap: CGLineCap

    public init(
        stroke: Color = Color.blue,
        background: Color = Color.blue.opacity(0.3),
        lineWidth: Length = 12.5.pmin,
        duration: TimeInterval = 1,
        indeterminate: Bool = true,
        lineCap: CGLineCap = .butt
    ) {
        self.stroke = stroke
        self.background = background
        self.lineWidth = lineWidth
        self.duration = duration
        self.indeterminate = indeterminate
        self.lineCap = lineCap
    }

    @State private var angle: Angle = .degrees(-90)

    public func makeBody(configuration: Configuration) -> some View {
        GeometryReader { geometry in
            let lineWidth = lineWidth.in(geometry)
            ZStack {
                let style = StrokeStyle(
                    lineWidth: lineWidth,
                    lineCap: lineCap
                )
                Circle()
                    .stroke(background, style: style)
                Circle()
                    .trim(from: 0, to: configuration.fractionCompleted.or(default: 0).cg)
                    .stroke(stroke, style: style)
                    .rotationEffect(angle)
                    .onAppear {
                        if indeterminate {
                            DispatchQueue.main.async {
                                withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
                                    angle = .degrees(angle.degrees + 360)
                                }
                            }
                        }
                    }
            }
            .padding(lineWidth / 2)
        }
        .scaledToFit()
    }
}

extension ProgressViewStyle where Self == IndeterminateProgressStyle {
    public static var indeterminate: IndeterminateProgressStyle { .init() }
}

#if DEBUG
struct IndeterminateProgressStyle_Previews: PreviewProvider {

    static var previews: some View {
        ProgressView(value: 0.25)
            .progressViewStyle(IndeterminateProgressStyle())
    }
}
#endif
