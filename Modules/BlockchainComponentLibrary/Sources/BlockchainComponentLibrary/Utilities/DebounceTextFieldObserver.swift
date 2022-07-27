// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import SwiftUI

public class DebounceTextFieldObserver<S: Scheduler>: ObservableObject {

    @Published public var input = ""
    @Published public private(set) var output = ""

    public init(delay: S.SchedulerTimeType.Stride, scheduler: S) {
        $input.debounce(for: delay, scheduler: scheduler).assign(to: &$output)
    }
}

extension DebounceTextFieldObserver where S == DispatchQueue {

    public convenience init(delay: S.SchedulerTimeType.Stride) {
        self.init(delay: delay, scheduler: DispatchQueue.main)
    }
}
