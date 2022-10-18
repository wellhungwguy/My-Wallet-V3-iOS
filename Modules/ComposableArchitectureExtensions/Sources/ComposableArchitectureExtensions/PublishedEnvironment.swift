import Combine
import ComposableArchitecture

public protocol PublishedEnvironment {

    associatedtype State
    associatedtype Action

    var subject: PassthroughSubject<(state: State, action: Action), Never> { get }
}

extension PublishedEnvironment {

    public var publisher: AnyPublisher<(state: State, action: Action), Never> {
        subject.eraseToAnyPublisher()
    }
}

extension Reducer where Environment: PublishedEnvironment, Environment.State == State, Environment.Action == Action {

    /// Returns a reducer that publishes ``State`` and `Action` to a passthrough subject
    /// after the reducer runs.
    public func published() -> Self {
        Self { state, action, environment in
            .merge(
                run(&state, action, environment),
                .fireAndForget { [state] in
                    environment.subject.send((state, action))
                }
            )
        }
    }
}

extension Publisher where Failure == Never {

    public func sink<Root, State, Action>(
        to handler: @escaping (Root) -> (State, Action) -> Void,
        on root: Root
    ) -> AnyCancellable where Root: AnyObject, Output == (state: State, action: Action) {
        sink { [weak root] value in
            guard let root else { return }
            handler(root)(value.state, value.action)
        }
    }
}
