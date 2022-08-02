import BlockchainNamespace
import Combine
import ComposableArchitecture
import MoneyKit
import PlatformKit

public struct AppModeSwitcherEnvironment {
    public let mainQueue: AnySchedulerOf<DispatchQueue>
    public let app: AppProtocol

    public init(
        mainQueue: AnySchedulerOf<DispatchQueue>,
        app: AppProtocol
    ) {
        self.mainQueue = mainQueue
        self.app = app
    }
}
