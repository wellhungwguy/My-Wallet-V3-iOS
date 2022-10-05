import ComposableArchitecture
import DIKit
import Foundation
import PlatformKit

public struct ViewIntroBackupEnvironment {
    public let mainQueue: AnySchedulerOf<DispatchQueue>
    public let onNext: () -> Void
    public let onSkip: () -> Void

    public init(
        mainQueue: AnySchedulerOf<DispatchQueue> = .main,
        onSkip: @escaping () -> Void,
        onNext: @escaping () -> Void
    ) {
        self.mainQueue = mainQueue
        self.onSkip = onSkip
        self.onNext = onNext
    }
}
