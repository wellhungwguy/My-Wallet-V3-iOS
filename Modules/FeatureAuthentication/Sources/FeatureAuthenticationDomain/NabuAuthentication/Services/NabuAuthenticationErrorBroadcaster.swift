// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import ToolKit

public protocol NabuAuthenticationErrorReceiverAPI {
    var userAlreadyRestored: AnyPublisher<String, Never> { get }
}

public protocol UserAlreadyRestoredHandlerAPI {
    func send(walletIdHint: String) -> AnyPublisher<Void, NabuAuthenticationExecutorError>
}

final class NabuAuthenticationErrorBroadcaster: NabuAuthenticationErrorReceiverAPI,
    UserAlreadyRestoredHandlerAPI
{

    private(set) var userAlreadyRestored: AnyPublisher<String, Never>
    private var userAlreadyRestoredSubject: PassthroughSubject<String, Never>

    init() {
        self.userAlreadyRestoredSubject = PassthroughSubject<String, Never>()
        self.userAlreadyRestored = userAlreadyRestoredSubject.eraseToAnyPublisher()
        NotificationCenter.when(.logout) { [weak self] _ in
            self?.reset()
        }
    }

    func send(walletIdHint: String) -> AnyPublisher<Void, NabuAuthenticationExecutorError> {
        userAlreadyRestoredSubject.send(walletIdHint)
        return .just(())
    }

    private func reset() {
        userAlreadyRestoredSubject = PassthroughSubject<String, Never>()
        userAlreadyRestored = userAlreadyRestoredSubject.eraseToAnyPublisher()
    }
}
