import ComposableArchitecture
import Foundation

public struct FeatureSuperAppIntro: ReducerProtocol {
    public init (onDismiss: @escaping () -> Void) {
        self.onDismiss = onDismiss
    }

    public func reduce(into state: inout State, action: Action) -> ComposableArchitecture.Effect<Action, Never> {
        switch action {
        case .didChangeStep(let step):
            state.currentStep = step
            return .none

        case .onDismiss:
            onDismiss()
            return .none
        }
    }

    var onDismiss: () -> Void

    public struct State: Equatable {
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

    public enum Action: Equatable {
        case didChangeStep(State.Step)
        case onDismiss
    }
}
