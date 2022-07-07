// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import Blockchain
import Combine
import EthereumKit
import MoneyKit
import PlatformKit
import RxSwift
import ToolKit
import WalletPayloadKit

class MockLegacyEthereumWallet: LegacyEthereumWalletAPI, LegacyWalletAPI, LegacyMnemonicAccessAPI {
    func checkIfEthereumAccountExists() -> Bool {
        unimplemented()
    }

    var underlyingEthereumAccounts: ((String?, ([[String: Any]]) -> Void, (String) -> Void) -> Void)?

    func ethereumAccounts(
        with secondPassword: String?,
        success: @escaping ([[String: Any]]) -> Void,
        error: @escaping (String) -> Void
    ) {
        underlyingEthereumAccounts!(secondPassword, success, error)
    }

    var underlyingGetLabelForEthereumAccount: ((String?, (String) -> Void, (String) -> Void) -> Void)?

    func getLabelForEthereumAccount(
        with secondPassword: String?,
        success: @escaping (String) -> Void,
        error: @escaping (String) -> Void
    ) {
        underlyingGetLabelForEthereumAccount!(secondPassword, success, error)
    }

    var underlyingGetEthereumAddress: ((String?, (String) -> Void, (String) -> Void) -> Void)?

    func getEthereumAddress(
        with secondPassword: String?,
        success: @escaping (String) -> Void,
        error: @escaping (String) -> Void
    ) {
        underlyingGetEthereumAddress!(secondPassword, success, error)
    }

    func getEthereumNote(
        for transaction: String,
        success: @escaping (String?) -> Void,
        error: @escaping (String) -> Void
    ) {
        unimplemented()
    }

    func setEthereumNote(for transaction: String, note: String?) {
        unimplemented()
    }

    func erc20Tokens(
        with secondPassword: String?,
        success: @escaping ([String: [String: Any]]) -> Void,
        error: @escaping (String) -> Void
    ) {
        unimplemented()
    }

    func saveERC20Tokens(
        with secondPassword: String?,
        tokensJSONString: String,
        success: @escaping () -> Void,
        error: @escaping (String) -> Void
    ) {
        unimplemented()
    }

    func recordLastEthereumTransaction(
        transactionHash: String,
        success: @escaping () -> Void,
        error: @escaping (String) -> Void
    ) {
        unimplemented()
    }

    func updateAccountLabel(_ cryptoCurrency: NonCustodialCoinCode, index: Int, label: String) -> Completable {
        unimplemented()
    }

    func createOrderPayment(
        orderTransaction: OrderTransactionLegacy,
        completion: @escaping (Result<[AnyHashable: Any], Wallet.CreateOrderError>) -> Void
    ) {
        unimplemented()
    }

    func sendOrderTransaction(
        _ legacyAssetType: LegacyAssetType,
        secondPassword: String?,
        completion: @escaping (Result<String, Wallet.SendOrderError>) -> Void
    ) {
        unimplemented()
    }

    func needsSecondPassword() -> Bool {
        unimplemented()
    }

    var mnemonic: AnyPublisher<Mnemonic, MnemonicAccessError> {
        unimplemented()
    }

    func mnemonic(with secondPassword: String?) -> AnyPublisher<Mnemonic, MnemonicAccessError> {
        unimplemented()
    }

    var mnemonicPromptingIfNeeded: AnyPublisher<Mnemonic, MnemonicAccessError> {
        unimplemented()
    }
}
