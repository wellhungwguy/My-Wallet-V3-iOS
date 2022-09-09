// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Errors
import PlatformKit
import RxSwift

public final class LocationUpdateService {
    private let client: KYCClientAPI

    public init(client: KYCClientAPI = resolve()) {
        self.client = client
    }

    public func update(address: UserAddress) -> Completable {
        save(address: address)
            .asObservable()
            .ignoreElements()
            .asCompletable()
    }

    public func save(address: UserAddress) -> AnyPublisher<Void, NabuNetworkError> {
        client.updateAddress(userAddress: address)
    }
}
