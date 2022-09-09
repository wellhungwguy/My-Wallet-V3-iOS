// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import BlockchainApp
import MoneyKit
import PlatformKit
import RxSwift
import ToolKit

class LegacyWalletMock: LegacyWalletAPI {

    func updateAccountLabel(
        _ cryptoCurrency: NonCustodialCoinCode,
        index: Int,
        label: String
    ) -> Completable {
        unimplemented()
    }

    func createOrderPayment(
        orderTransaction: OrderTransactionLegacy,
        completion: @escaping (Result<[AnyHashable: Any], Wallet.CreateOrderError>) -> Void
    ) {
        unimplemented()
    }

    func sendOrderTransaction(
        _ bitcoinChainCoin: LegacyAssetType,
        secondPassword: String?,
        completion: @escaping (Result<String, Wallet.SendOrderError>) -> Void
    ) {
        unimplemented()
    }

    func needsSecondPassword() -> Bool {
        unimplemented()
    }
}
