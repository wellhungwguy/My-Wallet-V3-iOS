// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import ToolKit

struct Trace {

    private class DebugTrace {

        private enum State {

            struct Started {
                let traceId: TraceID
                let startTime: Date
            }

            struct Ended {
                let traceId: TraceID
                let startTime: Date
                let endTime: Date
                let timeInterval: TimeInterval
            }

            case started(Started)
            case ended(Ended)
        }

        private var state: State

        func stop() {
            guard case .started(let started) = state else { return }

            let traceId = started.traceId
            let startTime = started.startTime
            let endTime = Date()
            let timeInterval = endTime.timeIntervalSince(startTime)
            let endState = State.Ended(
                traceId: traceId,
                startTime: startTime,
                endTime: endTime,
                timeInterval: timeInterval
            )
            state = .ended(endState)

            Self.printTrace(ended: endState)
        }

        convenience init(traceId: TraceID) {
            self.init(
                state: .started(.init(traceId: traceId, startTime: Date()))
            )
        }

        private init(state: State) {
            self.state = state
        }

        private static func printTrace(ended: State.Ended) {
            let traceId = ended.traceId
            let timeInterval = ended.timeInterval
            let seconds = timeInterval.string(with: 2)
            Logger.shared.debug(
                "Trace \(traceId), finished in \(seconds) seconds"
            )
        }
    }

    private enum TraceType {
        case debugTrace(DebugTrace)
        case remoteTrace(RemoteTrace)

        func stop() {
            switch self {
            case .debugTrace(let debugTrace):
                debugTrace.stop()
            case .remoteTrace(let remoteTrace):
                remoteTrace.stop()
            }
        }

        static func debugTrace(with traceId: TraceID) -> Self {
            .debugTrace(DebugTrace(traceId: traceId))
        }

        static func remoteTrace(
            with traceId: TraceID,
            properties: [String: String],
            create: PerformanceTracing.CreateRemoteTrace
        ) -> Self {
            let remoteTrace = create(traceId, properties)
            return .remoteTrace(remoteTrace)
        }
    }

    private let trace: TraceType

    private init(trace: TraceType) {
        self.trace = trace
    }

    func stop() {
        trace.stop()
    }

    static func createTrace(
        with traceId: TraceID,
        properties: [String: String],
        create: PerformanceTracing.CreateRemoteTrace
    ) -> Self {
        let traceType: TraceType = isDebug() ? .debugTrace(with: traceId)
        : .remoteTrace(with: traceId, properties: properties, create: create)
        return Self(trace: traceType)
    }

    private static func isDebug() -> Bool {
        var isDebug = false
#if DEBUG
        isDebug = true
#endif
        return isDebug
    }
}
