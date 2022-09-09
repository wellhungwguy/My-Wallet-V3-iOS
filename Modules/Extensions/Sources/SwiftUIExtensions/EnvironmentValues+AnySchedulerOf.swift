import CombineSchedulers
import SwiftUI

extension EnvironmentValues {

    public var scheduler: AnySchedulerOf<DispatchQueue> {
        get { self[AnySchedulerOfDispatchQueueEnvironmentValue.self] }
        set { self[AnySchedulerOfDispatchQueueEnvironmentValue.self] = newValue }
    }
}

private struct AnySchedulerOfDispatchQueueEnvironmentValue: EnvironmentKey {
    static var defaultValue = AnySchedulerOf<DispatchQueue>.main
}
