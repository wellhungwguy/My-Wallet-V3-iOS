import SwiftUI

public enum LoadingState<Value, Failure: Error> {
    case idle
    case loading
    case failed(Failure)
    case loaded(Value)
}

public protocol LoadableObject<Output, Failure>: ObservableObject {
    associatedtype Output
    associatedtype Failure: Error
    var state: LoadingState<Output, Failure> { get }
    func load()
}

public struct AsyncContentView<
    Source: LoadableObject,
    LoadingView: View,
    ErrorView: View,
    Content: View
>: View {

    @ObservedObject var source: Source
    var loadingView: LoadingView
    var errorView: (Source.Failure) -> ErrorView
    var content: (Source.Output) -> Content

    public init(
        source: Source,
        loadingView: LoadingView = ProgressView(),
        @ViewBuilder errorView: @escaping (Source.Failure) -> ErrorView,
        @ViewBuilder content: @escaping (Source.Output) -> Content
    ) {
        self.source = source
        self.loadingView = loadingView
        self.errorView = errorView
        self.content = content
    }

    public var body: some View {
        switch source.state {
        case .idle:
            Color.clear.onAppear(perform: source.load)
        case .loading:
            loadingView
        case .failed(let error):
            errorView(error)
        case .loaded(let output):
            content(output)
        }
    }
}

#if canImport(Combine)
import Combine

public class PublishedObject<Wrapped: Publisher, S: Scheduler>: LoadableObject {

    @Published public private(set) var state = LoadingState<Wrapped.Output, Wrapped.Failure>.idle

    private let publisher: Wrapped
    private var subscription: AnyCancellable?
    private var scheduler: S

    public init(publisher: Wrapped, scheduler: S = DispatchQueue.main) {
        self.publisher = publisher
        self.scheduler = scheduler
    }

    public func load() {
        state = .loading
        subscription = publisher
            .map(LoadingState.loaded)
            .catch { error in
                Just(LoadingState.failed(error))
            }
            .receive(on: scheduler)
            .sink { [weak self] state in
                self?.state = state
            }
    }
}

extension AsyncContentView {

    public init<P: Publisher>(
        source: P,
        loadingView: LoadingView = ProgressView(),
        @ViewBuilder errorView: @escaping (P.Failure) -> ErrorView,
        @ViewBuilder content: @escaping (P.Output) -> Content
    ) where Source == PublishedObject<P, DispatchQueue> {
        self.init(
            source: PublishedObject(publisher: source),
            loadingView: loadingView,
            errorView: errorView,
            content: content
        )
    }
}
#endif

extension AsyncContentView where Source.Failure == Never, ErrorView == EmptyView {

    public init(
        source: Source,
        loadingView: LoadingView,
        @ViewBuilder content: @escaping (Source.Output) -> Content
    ) {
        self.init(
            source: source,
            loadingView: loadingView,
            errorView: absurd,
            content: content
        )
    }

    public init(
        source: Source,
        @ViewBuilder content: @escaping (Source.Output) -> Content
    ) where LoadingView == ProgressView<EmptyView, EmptyView> {
        self.init(
            source: source,
            loadingView: ProgressView(),
            errorView: absurd,
            content: content
        )
    }
}

extension EmptyView {
    init<Ignored>(ignored: Ignored) {
        self = EmptyView()
    }
}
