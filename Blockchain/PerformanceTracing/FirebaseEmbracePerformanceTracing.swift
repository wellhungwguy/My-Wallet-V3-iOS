// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Embrace
import FirebasePerformance
import Foundation
import ObservabilityKit
import ToolKit

extension PerformanceTracing {

    public static let live: PerformanceTracingServiceAPI =
        PerformanceTracing.service(
            createRemoteTrace: { traceId, properties in
                var traces: [RemoteTrace] = []
                if let firebaseTrace = firebaseTracing(traceId: traceId, properties: properties) {
                    traces.append(firebaseTrace)
                }
                let embraceTrace = embraceTracing(traceId: traceId, properties: properties)
                traces.append(embraceTrace)
                return CompoundRemoteTrace(remoteTraces: traces)
            },
            listenForClearTraces: { clearTraces in
                NotificationCenter.when(.logout) { _ in
                    clearTraces()
                }
            }
        )

    public static let mock: PerformanceTracingServiceAPI =
        PerformanceTracing.service(
            createRemoteTrace: { _, _ in
                CompoundRemoteTrace(remoteTraces: [])
            },
            listenForClearTraces: { _ in }
        )

    private static func embraceTracing(traceId: TraceID, properties: [String: String]) -> RemoteTrace {
        EmbraceTrace.start(with: traceId, properties: properties)
    }

    private static func firebaseTracing(traceId: TraceID, properties: [String: String]) -> RemoteTrace? {
        guard let trace = Performance.startTrace(name: traceId.rawValue) else {
            return nil
        }
        for tuple in properties.prefix(5) {
            trace.setValue(tuple.value, forAttribute: tuple.key)
        }
        return trace
    }
}

private struct CompoundRemoteTrace: RemoteTrace {

    private let remoteTraces: [RemoteTrace]

    init(remoteTraces: [RemoteTrace]) {
        self.remoteTraces = remoteTraces
    }

    func stop() {
        for trace in remoteTraces {
            trace.stop()
        }
    }
}

extension FirebasePerformance.Trace: RemoteTrace {}

private struct EmbraceTrace: RemoteTrace {

    private let traceId: TraceID

    private init(traceId: TraceID, properties: [String: String]) {
        self.traceId = traceId

        Embrace.sharedInstance().startMoment(
            withName: traceId.rawValue,
            identifier: nil,
            properties: properties
        )
    }

    func stop() {
        Embrace.sharedInstance().endMoment(withName: traceId.rawValue)
    }

    static func start(with traceId: TraceID, properties: [String: String]) -> Self {
        EmbraceTrace(traceId: traceId, properties: properties)
    }
}
