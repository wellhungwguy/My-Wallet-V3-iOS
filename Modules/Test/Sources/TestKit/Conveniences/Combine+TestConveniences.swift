// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import CombineSchedulers

/// Configures a sequence of publishers to start in parallel.
///
/// - Parameter publishers: A sequence of publishers.
///
/// - Returns: A function to start the publishers in parallel.
public func configParallelStart(
    _ publishers: inout [AnyPublisher<some Any, some Any>]
) -> () -> Void {
    let startSubject = PassthroughSubject<Void, Never>()

    publishers = publishers.map { publisher in
        startSubject
            .first()
            .flatMap { publisher }
            .eraseToAnyPublisher()
    }

    return startSubject.send
}

extension DispatchQueue.SchedulerTimeType {

    public static var beginning: Self {
        .init(.init(uptimeNanoseconds: 1))
    }
}
