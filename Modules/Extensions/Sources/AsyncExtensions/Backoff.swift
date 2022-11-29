import SwiftExtensions

public actor ExponentialBackoff {

    var n = 0
    var rng: RandomNumberGenerator
    let unit: TimeInterval

    public init(
        unit: TimeInterval = 0.5,
        rng: RandomNumberGenerator = SystemRandomNumberGenerator()
    ) {
        self.unit = unit
        self.rng = rng
    }

    public func next() async throws {
        n += 1
        try await Task.sleep(
            nanoseconds: TimeInterval.random(
                in: unit...unit * pow(2, TimeInterval(n - 1)),
                using: &rng
            ).u64 * NSEC_PER_SEC
        )
    }

    public func reset() { n = 0 }
    public func count() -> Int { n }
}
