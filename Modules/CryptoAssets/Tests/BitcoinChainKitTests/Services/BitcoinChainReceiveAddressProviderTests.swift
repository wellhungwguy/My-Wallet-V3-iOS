// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import BitcoinChainKit
@testable import BitcoinChainKitMock
import Combine
import Errors
import TestKit
import ToolKit
import XCTest

// swiftlint:disable line_length
class BitcoinChainReceiveAddressProviderTests: XCTestCase {

    private var cancellables: Set<AnyCancellable>!
    private let queue = DispatchQueue(label: "receive.address.queue")

    override func setUp() {
        super.setUp()
        cancellables = []
    }

    func test_can_provide_first_address_index_bitcoin() {

        let mockMnemonicProvider: WalletMnemonicProvider = { () -> AnyPublisher<BitcoinChainKit.Mnemonic, Error> in
            .just(
                BitcoinChainKit.Mnemonic(
                    words: "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about"
                )
            )
        }

        let mockFetchMultiAddressFor: FetchMultiAddressFor = { _ -> AnyPublisher<BitcoinChainMultiAddressData, NetworkError> in
            .just(
                BitcoinChainMultiAddressData(
                    addresses: [],
                    latestBlockHeight: 0
                )
            )
        }

        let mockClient = APIClientMock()
        mockClient.underlyingUnspentOutputs = .just(UnspentOutputsResponse(unspent_outputs: []))
        let mockUnspentOutputRepo = UnspentOutputRepository(client: mockClient, coin: .bitcoin)

        let sut = BitcoinChainReceiveAddressProvider<BitcoinToken>(
            mnemonicProvider: mockMnemonicProvider,
            fetchMultiAddressFor: mockFetchMultiAddressFor,
            unspentOutputRepository: mockUnspentOutputRepo
        )

        let expectation = expectation(description: "provides correct first index")

        sut.firstReceiveAddressProvider(0)
            .sink { address in
                XCTAssertEqual(address, "bc1qcr8te4kr609gcawutmrza0j4xv80jy8z306fyu")
                expectation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 10)
    }

    func test_can_provide_address_based_on_latest_multiaddr_bitcoin() {

        let mockMnemonicProvider: WalletMnemonicProvider = { () -> AnyPublisher<Mnemonic, Error> in
            .just(
                Mnemonic(
                    words: "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about"
                )
            )
        }

        let mockFetchMultiAddressFor: FetchMultiAddressFor = { xpubs -> AnyPublisher<BitcoinChainMultiAddressData, NetworkError> in
            let items = xpubs.enumerated().map { index, value in
                BitcoinChainAddressResponse(
                    accountIndex: index + 1,
                    address: value.address,
                    changeIndex: 0,
                    finalBalance: 100,
                    nTx: 2,
                    totalReceived: 0,
                    totalSent: 0
                )
            }
            return .just(
                BitcoinChainMultiAddressData(
                    addresses: items,
                    latestBlockHeight: 0
                )
            )
        }

        let mockClient = APIClientMock()
        mockClient.underlyingUnspentOutputs = .just(UnspentOutputsResponse(unspent_outputs: []))
        let mockUnspentOutputRepo = UnspentOutputRepository(client: mockClient, coin: .bitcoin)

        let sut = BitcoinChainReceiveAddressProvider<BitcoinToken>(
            mnemonicProvider: mockMnemonicProvider,
            fetchMultiAddressFor: mockFetchMultiAddressFor,
            unspentOutputRepository: mockUnspentOutputRepo
        )

        let expectation = expectation(description: "provides correct first index")

        sut.receiveAddressProvider(0)
            .sink { address in
                XCTAssertEqual(address, "bc1qp59yckz4ae5c4efgw2s5wfyvrz0ala7rgvuz8z")
                expectation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 10)
    }

    func test_can_provide_first_address_index_bitcoin_cash() {

        let mockMnemonicProvider: WalletMnemonicProvider = { () -> AnyPublisher<Mnemonic, Error> in
            .just(
                Mnemonic(
                    words: "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about"
                )
            )
        }

        let mockFetchMultiAddressFor: FetchMultiAddressFor = { _ -> AnyPublisher<BitcoinChainMultiAddressData, NetworkError> in
            .just(
                BitcoinChainMultiAddressData(
                    addresses: [],
                    latestBlockHeight: 0
                )
            )
        }

        let mockClient = APIClientMock()
        mockClient.underlyingUnspentOutputs = .just(UnspentOutputsResponse(unspent_outputs: []))
        let mockUnspentOutputRepo = UnspentOutputRepository(client: mockClient, coin: .bitcoinCash)

        let sut = BitcoinChainReceiveAddressProvider<BitcoinCashToken>(
            mnemonicProvider: mockMnemonicProvider,
            fetchMultiAddressFor: mockFetchMultiAddressFor,
            unspentOutputRepository: mockUnspentOutputRepo
        )

        let expectation = expectation(description: "provides correct first index")

        sut.firstReceiveAddressProvider(0)
            .sink { address in
                XCTAssertEqual(address, "bitcoincash:qrvcdmgpk73zyfd8pmdl9wnuld36zh9n4gms8s0u59")
                expectation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 10)
    }

    func test_can_provide_address_based_on_latest_multiaddr_bitcoin_cash() {

        let mockMnemonicProvider: WalletMnemonicProvider = { () -> AnyPublisher<Mnemonic, Error> in
            .just(
                Mnemonic(
                    words: "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about"
                )
            )
        }

        let mockFetchMultiAddressFor: FetchMultiAddressFor = { xpubs -> AnyPublisher<BitcoinChainMultiAddressData, NetworkError> in
            let items = xpubs.enumerated().map { index, value in
                BitcoinChainAddressResponse(
                    accountIndex: index + 1,
                    address: value.address,
                    changeIndex: 0,
                    finalBalance: 100,
                    nTx: 2,
                    totalReceived: 0,
                    totalSent: 0
                )
            }
            return .just(
                BitcoinChainMultiAddressData(
                    addresses: items,
                    latestBlockHeight: 0
                )
            )
        }

        let mockClient = APIClientMock()
        mockClient.underlyingUnspentOutputs = .just(UnspentOutputsResponse(unspent_outputs: []))
        let mockUnspentOutputRepo = UnspentOutputRepository(client: mockClient, coin: .bitcoinCash)

        let sut = BitcoinChainReceiveAddressProvider<BitcoinCashToken>(
            mnemonicProvider: mockMnemonicProvider,
            fetchMultiAddressFor: mockFetchMultiAddressFor,
            unspentOutputRepository: mockUnspentOutputRepo
        )

        let expectation = expectation(description: "provides correct address")

        sut.receiveAddressProvider(0)
            .sink { address in
                XCTAssertEqual(address, "bitcoincash:qp4wzvqu73x22ft4r5tk8tz0aufdz9fescwtpcmhc7")
                expectation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 10)
    }
}
