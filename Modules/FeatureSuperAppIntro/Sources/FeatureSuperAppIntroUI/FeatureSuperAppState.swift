import SwiftUI

public struct FeatureSuperAppIntroState: Equatable {
    public init() {}

    public enum Step: Hashable {
        case walletJustGotBetter
        case newWayToNavigate
        case newHomeForDefi
        case tradingAccount
    }

    private let scrollEffectTransitionDistance: CGFloat = 300

    var scrollOffset: CGFloat = 0
    var currentStep: Step = .walletJustGotBetter

    var gradientBackgroundOpacity: Double {
        switch scrollOffset {
        case _ where scrollOffset >= 0:
            return 1
        case _ where scrollOffset <= -scrollEffectTransitionDistance:
            return 0
        default:
            return 1 - Double(scrollOffset / -scrollEffectTransitionDistance)
        }
    }
}
