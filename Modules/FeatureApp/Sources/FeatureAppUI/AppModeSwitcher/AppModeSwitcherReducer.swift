import BlockchainNamespace
import ComposableArchitecture
import ToolKit

public enum AppModeSwitcherModule {}

extension AppModeSwitcherModule {
    public static var reducer: Reducer<AppModeSwitcherState, AppModeSwitcherAction, AppModeSwitcherEnvironment> {
        .init { _, action, environment in
            switch action {
            case .onDefiTapped:
                return Effect.fireAndForget {
                    environment.app.state.set(blockchain.app.mode, to: AppMode.defi.rawValue)
                }

            case .onBrokerageTapped:
                return Effect.fireAndForget {
                    environment.app.state.set(blockchain.app.mode, to: AppMode.trading.rawValue)
                }
            }
        }
    }
}
