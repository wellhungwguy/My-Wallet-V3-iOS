// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Network

final class Reachability {

    private let monitor: NWPathMonitor

    init(monitor: NWPathMonitor = .init()) {
        self.monitor = monitor
        monitor.pathUpdateHandler = { path in
            print("Reachability: \(path.status).")
        }
        monitor.start(queue: DispatchQueue.global(qos: .default))
    }

    deinit {
        print("Reachability: Cancel.")
        monitor.cancel()
    }

    var hasInternetConnection: Bool {
#if TARGET_OS_SIMULATOR
        true
#else
        monitor.currentPath.status != .unsatisfied
#endif
    }
}
