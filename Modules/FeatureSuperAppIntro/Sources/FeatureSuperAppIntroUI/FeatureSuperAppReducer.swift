import ComposableArchitecture

public enum FeatureSuperAppIntroModule {}

extension FeatureSuperAppIntroModule {
    public static var reducer: Reducer<FeatureSuperAppIntroState, FeatureSuperAppIntroAction, Void> {
        .init { state, action, _ in
            switch action {
            case .didChangeStep(let step):
                state.currentStep = step
                return .none
            }
        }
    }
}
