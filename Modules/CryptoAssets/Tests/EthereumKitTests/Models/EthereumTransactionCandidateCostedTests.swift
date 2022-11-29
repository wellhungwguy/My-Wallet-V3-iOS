// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
@testable import EthereumKit
@testable import EthereumKitMock
@testable import MoneyKit
import PlatformKit
import XCTest

final class EthereumTransactionCandidateCostedTests: XCTestCase {

    func test_build_transaction_transfer() {
        let toAddress = EthereumAddress(address: "0x3535353535353535353535353535353535353535", network: .ethereum)!
        let value = BigUInt("0.01658472", decimals: CryptoCurrency.ethereum.precision)!
        let nonce = MockEthereumWalletTestData.Transaction.nonce
        let gasPrice = MockEthereumWalletTestData.Transaction.gasPrice
        let gasLimit = MockEthereumWalletTestData.Transaction.gasLimit
        let chainID = MockEthereumWalletTestData.Transaction.chainID
        let message = "This is a message."
        let data = Data(message.utf8)

        let transaction = EthereumTransactionCandidate(
            to: toAddress,
            gasPrice: gasPrice,
            gasLimit: gasLimit,
            value: value,
            nonce: nonce,
            chainID: chainID,
            transferType: .transfer(data: data)
        )

        let result = EthereumTransactionCandidateCosted.create(
            transaction: transaction
        )

        guard case .success(let costed) = result else {
            XCTFail("The transaction should be built successfully")
            return
        }

        let input = costed.transaction

        XCTAssertEqual(input.gasLimit.hexString, "5208")
        XCTAssertEqual(input.gasPrice.hexString, "028fa6ae00")
        XCTAssertEqual(input.nonce.hexString, "09")
        XCTAssertEqual(input.toAddress, toAddress.publicKey)
        XCTAssertEqual(input.chainID.hexString, "01")

        if case .transfer = input.transaction.transactionOneof {} else {
            XCTFail("Transaction is not a 'transfer'")
        }

        XCTAssertEqual(input.transaction.transfer.amount.hexString, "3aebb7084ca000")
        XCTAssertEqual(input.transaction.transfer.data.hexString, data.hexString)
    }

    func test_build_transaction_erc20Transfer() throws {
        let toAddress = EthereumAddress(address: "0x5322b34c88ed0691971bf52a7047448f0f4efc84", network: .ethereum)!
        let tokenContract = EthereumAddress(address: "0x6b175474e89094c44da98b954eedeac495271d0f", network: .ethereum)!
        let addressReference = EthereumAddress(address: "0x3535353535353535353535353535353535353535", network: .ethereum)!

        let transaction = EthereumTransactionCandidate(
            to: toAddress,
            gasPrice: 42000000000,
            gasLimit: 78009,
            value: 2000000000000000000,
            nonce: 0,
            chainID: 1,
            transferType: .erc20Transfer(contract: tokenContract, addressReference: addressReference)
        )

        let result = EthereumTransactionCandidateCosted.create(
            transaction: transaction
        )

        guard case .success(let costed) = result else {
            XCTFail("The transaction should be built successfully")
            return
        }

        let input = costed.transaction

        XCTAssertEqual(input.gasLimit.hexValue.withHex, "0x0130b9")
        XCTAssertEqual(input.gasPrice.hexValue.withHex, "0x09c7652400")
        XCTAssertEqual(input.nonce.hexString.withHex, "0x00")
        XCTAssertEqual(input.toAddress, tokenContract.publicKey)
        XCTAssertEqual(input.chainID.hexString.withHex, "0x01")

        if case .erc20Transfer = input.transaction.transactionOneof {} else {
            XCTFail("Transaction is not a 'transfer'")
        }

        XCTAssertEqual(input.transaction.erc20Transfer.amount.hexString.withHex, "0x1bc16d674ec80000")
        XCTAssertEqual(input.transaction.erc20Transfer.to, toAddress.publicKey)
        XCTAssertEqual(input.transaction.erc20Transfer.addressReference, addressReference.publicKey)
    }

    func test_build_transaction_failure_gas_limit() {
        let toAddress = EthereumAddress(address: "0x3535353535353535353535353535353535353535", network: .ethereum)!
        let value = BigUInt("0.01658472", decimals: CryptoCurrency.ethereum.precision)!
        let nonce = MockEthereumWalletTestData.Transaction.nonce
        let gasPrice: BigUInt = MockEthereumWalletTestData.Transaction.gasPrice
        let gasLimit: BigUInt = 0

        let transaction = EthereumTransactionCandidate(
            to: toAddress,
            gasPrice: gasPrice,
            gasLimit: gasLimit,
            value: value,
            nonce: nonce,
            chainID: 1,
            transferType: .transfer()
        )

        let result = EthereumTransactionCandidateCosted.create(
            transaction: transaction
        )

        guard case .failure(let error) = result else {
            XCTFail("The transaction should not be built")
            return
        }
        XCTAssertEqual(error, EthereumKitValidationError.noGasLimit)
    }

    func test_build_transaction_failure_gas_price() {
        let toAddress = EthereumAddress(address: "0x3535353535353535353535353535353535353535", network: .ethereum)!
        let value = BigUInt("0.01658472", decimals: CryptoCurrency.ethereum.precision)!
        let nonce = MockEthereumWalletTestData.Transaction.nonce
        let gasPrice: BigUInt = 0
        let gasLimit = MockEthereumWalletTestData.Transaction.gasLimit

        let transaction = EthereumTransactionCandidate(
            to: toAddress,
            gasPrice: gasPrice,
            gasLimit: gasLimit,
            value: value,
            nonce: nonce,
            chainID: 1,
            transferType: .transfer()
        )

        let result = EthereumTransactionCandidateCosted.create(
            transaction: transaction
        )

        guard case .failure(let error) = result else {
            XCTFail("The transaction should not be built")
            return
        }
        XCTAssertEqual(error, EthereumKitValidationError.noGasPrice)
    }
}
