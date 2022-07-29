// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import MoneyKit
import PlatformKit
import RxSwift

final class MockCoincore: CoincoreAPI {
    var allAccounts: AnyPublisher<AccountGroup, CoincoreError> = .empty()
    func account(
        where isIncluded: @escaping (BlockchainAccount) -> Bool
    ) -> AnyPublisher<[BlockchainAccount], Error> {
        .empty()
    }
    var allAssets: [Asset] = []
    var fiatAsset: Asset = MockAsset()
    var cryptoAssets: [CryptoAsset] = [MockAsset()]
    var initializePublisherCalled = false

    func initialize() -> AnyPublisher<Void, CoincoreError> {
        initializePublisherCalled = true
        return .just(())
    }

    func getTransactionTargets(
        sourceAccount: BlockchainAccount,
        action: AssetAction
    ) -> AnyPublisher<[SingleAccount], CoincoreError> {
        .just([])
    }

    subscript(cryptoCurrency: CryptoCurrency) -> CryptoAsset {
        cryptoAssets.first(where: { $0.asset == cryptoCurrency })!
    }
}

class MockAsset: CryptoAsset {

    var accountGroup: AccountGroup = CryptoAccountCustodialGroup(asset: .bitcoin)

    var asset: CryptoCurrency {
        accountGroup.currencyType.cryptoCurrency!
    }

    func initialize() -> AnyPublisher<Void, AssetError> {
        .just(())
    }

    var defaultAccount: AnyPublisher<SingleAccount, CryptoAssetError> {
        guard let account = accountGroup.accounts.first else {
            return .failure(.noDefaultAccount)
        }
        return .just(account)
    }

    var canTransactToCustodial: AnyPublisher<Bool, Never> {
        .just(true)
    }

    func parse(
        address: String,
        label: String,
        onTxCompleted: @escaping (TransactionResult) -> Completable
    ) -> Result<CryptoReceiveAddress, CryptoReceiveAddressFactoryError> {
        .failure(.invalidAddress)
    }

    func accountGroup(filter: AssetFilter) -> AnyPublisher<AccountGroup, Never> {
        .just(accountGroup)
    }

    func transactionTargets(account: SingleAccount) -> AnyPublisher<[SingleAccount], Never> {
        .just(accountGroup.accounts)
    }

    func parse(address: String) -> AnyPublisher<ReceiveAddress?, Never> {
        .just(nil)
    }
}
