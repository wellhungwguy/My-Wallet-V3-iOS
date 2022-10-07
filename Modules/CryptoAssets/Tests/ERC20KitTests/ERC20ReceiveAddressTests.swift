// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import ERC20Kit
@testable import EthereumKit
@testable import MoneyDomainKitMock
import MoneyKit
import RxSwift
import XCTest

final class ERC20ReceiveAddressTests: XCTestCase {

    enum TestCase {
        static let address = "0x8e23ee67d1332ad560396262c48ffbb01f93d052"
        static let contract = "0xfb6916095ca1df60bb79Ce92ce3ea74c37c5d359"
        static let sendString = "ethereum:\(address)@33?gasPrice=10&gasLimit=20"
        static let paySendString = "ethereum:pay-\(address)@33?gasPrice=10&gasLimit=20"
        static let transferString = "ethereum:\(contract)@33/transfer?address=\(address)&uint256=1"
    }

    var factory: ERC20ExternalAssetAddressFactory!

    override func setUp() {
        super.setUp()
        let asset = CryptoCurrency.mockERC20(
            symbol: "AAA",
            displaySymbol: "AAA",
            name: "AAA",
            erc20Address: TestCase.contract,
            precision: 18,
            sortIndex: 0
        )
        let currenciesService = MockEnabledCurrenciesService()
        currenciesService.allEnabledCryptoCurrencies = [
            asset
        ]
        factory = ERC20ExternalAssetAddressFactory(
            asset: asset,
            enabledCurrenciesService: currenciesService
        )
    }

    override func tearDown() {
        factory = nil
        super.tearDown()
    }

    func testQRCodeMetadataTransfer() {
        let receiveAddress = receiveAddress(TestCase.transferString)!
        XCTAssertEqual(receiveAddress.qrCodeMetadata.content, TestCase.address)
        XCTAssertEqual(receiveAddress.qrCodeMetadata.title, TestCase.address)
    }

    func testQRCodeMetadataSend() {
        let receiveAddress = receiveAddress(TestCase.sendString)!
        XCTAssertEqual(receiveAddress.qrCodeMetadata.content, TestCase.address)
        XCTAssertEqual(receiveAddress.qrCodeMetadata.title, TestCase.address)
    }

    func testQRCodeMetadataPaySend() {
        let receiveAddress = receiveAddress(TestCase.paySendString)!
        XCTAssertEqual(receiveAddress.qrCodeMetadata.content, TestCase.address)
        XCTAssertEqual(receiveAddress.qrCodeMetadata.title, TestCase.address)
    }

    private func receiveAddress(_ address: String) -> ERC20ReceiveAddress? {
        try? factory
            .makeExternalAssetAddress(
                address: address,
                label: "Label",
                onTxCompleted: { _ in .empty() }
            )
            .get() as? ERC20ReceiveAddress
    }
}
