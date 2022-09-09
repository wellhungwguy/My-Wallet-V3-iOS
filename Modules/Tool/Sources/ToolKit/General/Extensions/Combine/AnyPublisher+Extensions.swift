// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine

extension Publisher {

    public var resultPublisher: AnyPublisher<Result<Output, Failure>, Never> {
        flatMap { value -> AnyPublisher<Result<Output, Failure>, Failure> in
            .just(.success(value))
        }
        .catch { error -> AnyPublisher<Result<Output, Failure>, Never> in
            .just(.failure(error))
        }
        .eraseToAnyPublisher()
    }
}

extension Publisher {

    public func crashOnError() -> AnyPublisher<Output, Failure> {
        self.catch { error -> AnyPublisher<Output, Failure> in
            fatalError(error.localizedDescription)
        }
        .eraseToAnyPublisher()
    }

    public func crashOnError() -> AnyPublisher<Output, Never> {
        self.catch { error -> AnyPublisher<Output, Never> in
            fatalError(error.localizedDescription)
        }
        .eraseToAnyPublisher()
    }
}

extension Publisher {

    public func recordErrors(on recorder: ErrorRecording?) -> AnyPublisher<Output, Failure> {
        handleEvents(
            receiveCompletion: { completion in
                guard case .failure(let error) = completion else {
                    return
                }
                recorder?.error(error)
            }
        )
        .eraseToAnyPublisher()
    }

    public func recordErrors(on recorder: ErrorRecording?, enabled: Bool) -> AnyPublisher<Output, Failure> {
        guard enabled else {
            return eraseToAnyPublisher()
        }
        return recordErrors(on: recorder)
    }
}

extension Publisher {
    /// - Parameters:
    ///   - transform: A mapping function that converts `Result<Output,Failure>` to another type.
    /// - Returns: A publiser of type <Result<Output, Failure>, Never>
    public func mapToResult() -> AnyPublisher<Result<Output, Failure>, Never> {
        map(Result.success)
            .catch { Just(.failure($0)) }
            .eraseToAnyPublisher()
    }
}
