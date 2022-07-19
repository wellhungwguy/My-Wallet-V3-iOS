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
            guard BuildFlag.isInternal else {
                // log error on prod/alpha builds
                tracer.logError(error: error, properties: nil)
                return
            }
            // crash on internal builds
            fatalError("[Error]: \(String(describing: error))")
        })
        .eraseToAnyPublisher()
    }
}
