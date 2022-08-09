// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import Foundation
import ToolKit

final class PerformanceTracingService: PerformanceTracingServiceAPI {

    typealias CreateTrace = (TraceID, [String: String]) -> Trace?

    private let traces: Atomic<[TraceID: Trace]>
    private let createTrace: CreateTrace

    init(
        createTrace: @escaping CreateTrace,
        initialTraces: [TraceID: Trace] = [:],
        listenForClearTraces: @escaping PerformanceTracing.ListenForClearTraces
    ) {
        traces = Atomic(initialTraces)
        self.createTrace = createTrace

        listenForClearTraces { [traces] in
            traces.mutate { currentTraces in
                currentTraces = [:]
            }
        }
    }

    func begin(trace traceId: TraceID, properties: [String: String]?) {
        removeTrace(with: traceId)
        if let trace = createTrace(traceId, properties ?? [:]) {
            traces.mutate { traces in
                traces[traceId] = trace
            }
        }
    }

    func end(trace traceId: TraceID) {
        guard let trace = traces.value[traceId] else { return }
        trace.stop()
        removeTrace(with: traceId)
    }

    private func removeTrace(with traceId: TraceID) {
        traces.mutate { traces in
            traces.removeValue(forKey: traceId)
        }
    }
}

struct NamepaceTrace: Codable {
    let start: Tag.Reference
    let stop: Tag.Reference
    let id: String
    let context: [String: Tag.Reference]
}

public final class PerformanceTracingObserver: Session.Observer {

    unowned let app: AppProtocol
    private let service: PerformanceTracingServiceAPI

    private var bag: Set<AnyCancellable> = []

    public init(app: AppProtocol, service: PerformanceTracingServiceAPI) {
        self.app = app
        self.service = service
    }

    public func start() {
        app.publisher(for: blockchain.app.configuration.performance.tracing, as: [NamepaceTrace?].self)
            .compactMap { result in result.value?.compacted() }
            .flatMap { [app, service] traces -> AnyPublisher<Session.Event, Never> in
                let starts = traces.map { trace in
                    app.on(trace.start)
                        .handleEvents(
                            receiveOutput: { event in
                                let properties = trace.context.reduce(into: [String: String]()) { properties, next in
                                    properties[next.key] = (
                                        try? event.reference.context[next.value].decode()
                                    ) ?? (
                                        try? event.context[next.value].decode()
                                    ) ?? (
                                        try? app.state.get(next.value)
                                    ) ?? (
                                        try? app.remoteConfiguration.get(next.value)
                                    )
                                }
                                service.begin(trace: TraceID(trace.id), properties: properties)
                            }
                        )
                        .eraseToAnyPublisher()
                }
                let ends = traces.map { trace in
                    app.on(trace.stop)
                        .handleEvents(receiveOutput: { _ in service.end(trace: TraceID(trace.id)) })
                        .eraseToAnyPublisher()
                }
                return (starts + ends).merge().eraseToAnyPublisher()
            }
            .subscribe()
            .store(in: &bag)
    }

    public func stop() {
        bag.removeAll()
    }
}
