// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public final class ObservabilityService: ObservabilityServiceAPI {

    private let client: ObservabilityClientAPI

    public init(
        client: ObservabilityClientAPI
    ) {
        self.client = client
    }

    public func start(with appKey: String) {
        client.start(withKey: appKey)
    }

    public func addSessionProperty(_ value: String, withKey key: String, permanent: Bool) -> Bool {
        client.addSessionProperty(value, withKey: key, permanent: permanent)
    }
}
