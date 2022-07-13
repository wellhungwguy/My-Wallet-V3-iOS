// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DelegatedSelfCustodyDomain

final class AssetSupportService {

    private let stacksSupport: DelegatedCustodyStacksSupportServiceAPI

    init(stacksSupport: DelegatedCustodyStacksSupportServiceAPI) {
        self.stacksSupport = stacksSupport
    }

    /// Stream collection of supported assets.
    func supportedDerivations() -> AnyPublisher<[DelegatedCustodyDerivation], Error> {
        stacksSupport
            .isEnabled
            .eraseError()
            .flatMap { isEnabled -> AnyPublisher<[DelegatedCustodyDerivation], Error> in
                guard isEnabled else {
                    return .just([])
                }
                return .just([.stacks])
            }
            .eraseToAnyPublisher()
    }
}
