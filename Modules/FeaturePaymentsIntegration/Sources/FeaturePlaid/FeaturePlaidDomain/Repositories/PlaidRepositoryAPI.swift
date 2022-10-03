// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors

public protocol PlaidRepositoryAPI {
    // MARK: - Get Link Token For Linking a Bank

    func getLinkToken() -> AnyPublisher<LinkAccountInfo, NabuError>

    // MARK: - Get Link Token For Migrating or relinking a Bank

    func getLinkToken(
        accountId: String
    ) -> AnyPublisher<LinkAccountInfo, NabuError>

    // MARK: - Post data of new added bank and old account to be migrated

    /// New account is linked with Plaid and the old with some other partner

    func updatePlaidAccount(
        _ accountId: String,
        attributes: PlaidAccountAttributes
    ) -> AnyPublisher<Bool, NabuError>

    // MARK: - Wait for recently added/updated/migrated bank to be active

    func waitForActivationOfLinkedBank(
        id: String
    ) -> AnyPublisher<LinkedBankData?, NabuError>

    func getSettlementInfo(
        accountId: String,
        amount: String
    ) -> AnyPublisher<SettlementInfo, NabuError>
}
