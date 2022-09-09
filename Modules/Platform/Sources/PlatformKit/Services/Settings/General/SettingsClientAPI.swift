// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors

public protocol UpdateCurrencySettingsClientAPI: AnyObject {

    func updatePublisher(
        currency: String,
        context: FlowContext,
        guid: String,
        sharedKey: String
    ) -> AnyPublisher<Void, CurrencyUpdateError>
}

/// Protocol definition for interacting with the `WalletSettings` object.
protocol SettingsClientAPI: UpdateCurrencySettingsClientAPI {

    /// Fetches the wallet settings from the backend.
    /// - Parameter guid: The wallet identifier that must be valid.
    /// - Parameter sharedKey: A shared key that must be valid.
    /// - Returns: a `Single` that wraps a `SettingsResponse`.
    func settings(
        by guid: String,
        sharedKey: String
    ) -> AnyPublisher<SettingsResponse, NetworkError>

    /// Updates the user's email.
    /// - Parameter email: The email value.
    /// - Parameter context: The context in which the update is happening.
    /// - Parameter guid: The wallet identifier that must be valid.
    /// - Parameter sharedKey: A shared key that must be valid.
    /// - Returns: a `Completable` with the new user email.
    func update(
        email: String,
        context: FlowContext?,
        guid: String,
        sharedKey: String
    ) -> AnyPublisher<String, NetworkError>

    /// Updates the user's mobile number.
    /// - Parameter smsNumber: The mobile number value.
    /// - Parameter context: The context in which the update is happening.
    /// - Parameter guid: The wallet identifier that must be valid.
    /// - Parameter sharedKey: A shared key that must be valid.
    /// - Returns: a `Completable`.
    func update(
        smsNumber: String,
        context: FlowContext?,
        guid: String,
        sharedKey: String
    ) -> AnyPublisher<Void, NetworkError>

    /// Updates the last transaction time performed by this wallet.
    ///
    /// This method should be invoked when:
    ///   - the user buys crypto using fiat
    ///   - the user sends crypto
    /// - Parameter guid: The wallet identifier that must be valid.
    /// - Parameter sharedKey: A shared key that must be valid.
    /// - Returns: a `Completable`.
    func updateLastTransactionTime(
        guid: String,
        sharedKey: String
    ) -> AnyPublisher<Void, NetworkError>

    /// Verifies the user's mobile number.
    /// - Parameter code: The SMS code
    /// - Parameter guid: The wallet identifier that must be valid.
    /// - Parameter sharedKey: A shared key that must be valid.
    /// - Returns: a `Completable`.
    func verifySMS(
        code: String,
        guid: String,
        sharedKey: String
    ) -> AnyPublisher<Void, NetworkError>

    func smsTwoFactorAuthentication(
        enabled: Bool,
        guid: String,
        sharedKey: String
    ) -> AnyPublisher<Void, NetworkError>

    func emailNotifications(
        enabled: Bool,
        guid: String,
        sharedKey: String
    ) -> AnyPublisher<Void, NetworkError>

    func update(
        currency: String,
        context: FlowContext,
        guid: String,
        sharedKey: String
    ) -> AnyPublisher<Void, NetworkError>
}
