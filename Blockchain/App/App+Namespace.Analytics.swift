import AnalyticsKit
import BlockchainNamespace
import Combine
import ToolKit
import UIKit

final class AppAnalyticsObserver: Session.Observer {

    typealias Analytics = [Tag.Reference: Value]

    struct Value: Decodable {

        struct Condition: Decodable {
            let `if`: [Tag.Reference]?
            let unless: [Tag.Reference]?
        }

        let name: String
        let context: [String: Either<Tag.Reference, AnyJSON>]?
        let condition: Condition?
    }

    unowned let app: AppProtocol
    let recorder: AnalyticsEventRecorderAPI

    init(
        app: AppProtocol,
        recorder: AnalyticsEventRecorderAPI = DIKit.resolve()
    ) {
        self.app = app
        self.recorder = recorder
    }

    private var segment: AnyCancellable? {
        didSet { oldValue?.cancel() }
    }

    private var firebase: AnyCancellable? {
        didSet { oldValue?.cancel() }
    }

    func start() {
        if segment != nil || firebase != nil {
            assertionFailure("Attempted to start what is already started 💣")
        }
        segment = app.publisher(for: blockchain.ux.type.analytics.configuration.segment.map, as: [String: Value].self)
            .compactMap(\.value)
            .map { [language = app.language] analytics -> Analytics in
                analytics.compactMapKeys { id in try? Tag.Reference(id: id, in: language) }
            }
            .combineLatest(Just(.nabu))
            .sink(to: My.observe, on: self)

        firebase = app.publisher(for: blockchain.ux.type.analytics.configuration.firebase.map, as: [String: Value].self)
            .compactMap(\.value)
            .map { [language = app.language] analytics -> Analytics in
                analytics.compactMapKeys { id in try? Tag.Reference(id: id, in: language) }
            }
            .combineLatest(Just(.firebase))
            .sink(to: My.observe, on: self)
    }

    func stop() {
        (segment, firebase) = (nil, nil)
        bag.segment.removeAll()
        bag.firebase.removeAll()
    }

    private var bag = (segment: Set<AnyCancellable>(), firebase: Set<AnyCancellable>())

    func observe(_ events: Analytics, _ type: AnalyticsEventType) {
        switch type {
        case .firebase: bag.firebase.removeAll()
        case .nabu: bag.segment.removeAll()
        }
        for (event, value) in events {
            let subscription = app.on(event)
                .combineLatest(Just(value), Just(type))
                .sink(to: My.record, on: self)
            switch type {
            case .firebase: subscription.store(in: &bag.firebase)
            case .nabu: subscription.store(in: &bag.segment)
            }
        }
    }

    func record(_ event: Session.Event, _ value: Value, _ type: AnalyticsEventType) {
        if let condition = value.condition {
            guard
                (condition.if ?? []).allSatisfy(isYes),
                (condition.unless ?? []).none(isYes)
            else { return }
        }
        Task { @MainActor in
            do {
                try recorder.record(
                    event: AnyAnalyticsEvent(
                        type: type,
                        timestamp: event.date,
                        name: value.name,
                        params: value.context?.mapValues { either -> Any in
                            switch either {
                            case .left(let ref):
                                return try event.reference.context[ref]
                                    ?? event.context[ref]
                                    ?? app.state.get(ref)
                            case .right(let any):
                                return any.thing
                            }
                        }
                    )
                )
            } catch {
                app.post(error: error)
            }
        }
    }

    func isYes(_ ref: Tag.Reference) -> Bool {
        switch ref.tag {
        case blockchain.session.state.value:
            return app.state.result(for: ref).isYes
        case blockchain.session.configuration.value:
            return app.remoteConfiguration.result(for: ref).isYes
        default:
            return false
        }
    }
}

struct AnyAnalyticsEvent: AnalyticsEvent {
    var type: AnalyticsEventType
    let timestamp: Date?
    let name: String
    let params: [String: Any]?
}
