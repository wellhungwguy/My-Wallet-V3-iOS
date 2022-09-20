// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import ObservabilityKit
import ToolKit

extension Publisher {
    /// Logs error on prod/alpha build and crashes on internal builds
    /// - Parameter tracer: An implementation of `LogMessageServiceAPI`
    /// - Returns: `AnyPublisher<Output, Failure>`
    func logErrorOrCrash(
        tracer: LogMessageServiceAPI
    ) -> AnyPublisher<Output, Failure> {
        handleEvents(receiveCompletion: { [tracer] completion in
            guard case .failure(let error) = completion else {
                return
            }
            if isDebug {
                fatalError("[Error]: \(String(describing: error))")
            }
            tracer.logError(error: error, properties: nil)
        })
        .eraseToAnyPublisher()
    }
}

private var isDebug: Bool {
    var isDebug = false
#if DEBUG
    isDebug = true
#endif
    return isDebug
}
