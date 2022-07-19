public protocol SessionObserver: AnyObject, CustomStringConvertible {
    func start()
    func stop()
}

extension Session {

    public typealias Observer = SessionObserver

    public class Observers {

        var observers: Set<AnyHashable> = []

        public func insert<O: Observer>(_ observer: O) {
            let (inserted, _) = observers.insert(AnyHashable(Box(observer)))
            guard inserted else { return }
            observer.start()
        }

        public func remove<O: Observer>(_ observer: O) {
            (observers.remove(AnyHashable(Box(observer))) as? Box<O>)?.value?.stop()
        }
    }
}

extension SessionObserver {

    public var description: String {
        "\(type(of: self))"
    }
}

private struct Box<Wrapped: AnyObject> {
    var value: Wrapped?
    init(_ value: Wrapped? = nil) {
        self.value = value
    }
}

extension Box: Equatable {

    static func == (lhs: Box, rhs: Box) -> Bool {
        guard let lhs = lhs.value, let rhs = rhs.value else {
            return lhs.value == nil && rhs.value == nil
        }
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
}

extension Box: Hashable {

    func hash(into hasher: inout Hasher) {
        guard let value = value else { return }
        hasher.combine(ObjectIdentifier(value))
    }
}
