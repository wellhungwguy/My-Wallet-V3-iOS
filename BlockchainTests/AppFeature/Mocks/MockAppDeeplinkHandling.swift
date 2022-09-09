// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine

@testable import BlockchainApp
@testable import FeatureAppUI

final class MockAppDeeplinkHandler: AppDeeplinkHandlerAPI {

    var passthroughSubject = PassthroughSubject<DeeplinkOutcome, AppDeeplinkError>()
    var canHandle: Bool = false

    func canHandle(deeplink: DeeplinkContext) -> Bool {
        canHandle
    }

    func handle(deeplink: DeeplinkContext) -> AnyPublisher<DeeplinkOutcome, AppDeeplinkError> {
        passthroughSubject.eraseToAnyPublisher()
    }
}
