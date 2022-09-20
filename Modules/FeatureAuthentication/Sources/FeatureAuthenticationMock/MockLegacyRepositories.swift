import Combine
import FeatureAuthenticationDomain

public class MockLegacyGuidRepository: LegacyGuidRepositoryAPI {
    public var guid: AnyPublisher<String?, Never> {
        .just(directGuid)
    }

    public var directGuid: String?

    public func set(guid: String?) -> AnyPublisher<Void, Never> {
        directGuid = guid
        return .just(())
    }

    public func directSet(guid: String?) {
        directGuid = guid
    }
}

public class MockLegacySharedKeyRepository: LegacySharedKeyRepositoryAPI {
    public var sharedKey: AnyPublisher<String?, Never> {
        .just(directSharedKey)
    }

    public var directSharedKey: String?

    public func set(sharedKey: String?) -> AnyPublisher<Void, Never> {
        directSharedKey = sharedKey
        return .just(())
    }

    public func directSet(sharedKey: String?) {
        directSharedKey = sharedKey
    }
}
