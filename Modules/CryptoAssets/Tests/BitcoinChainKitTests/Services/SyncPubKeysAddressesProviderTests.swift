// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import BitcoinChainKit
@testable import BitcoinChainKitMock
@testable import WalletPayloadKit

import Combine
import Errors
import TestKit
import ToolKit
import XCTest

// swiftlint:disable line_length type_body_length function_body_length
class SyncPubKeysAddressesProviderTests: XCTestCase {

    private var cancellables: Set<AnyCancellable>!
    private let queue = DispatchQueue(label: "receive.address.queue")

    override func setUp() {
        super.setUp()
        cancellables = []
    }

    func test_provides_correct_addresses_for_syncing() {
        let mockMnemonicProvider: WalletMnemonicProvider = { () -> AnyPublisher<BitcoinChainKit.Mnemonic, Error> in
            .just(
                BitcoinChainKit.Mnemonic(
                    words: "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about"
                )
            )
        }

        let mockFetchMultiAddressFor: FetchMultiAddressFor = { xpubs -> AnyPublisher<BitcoinChainMultiAddressData, NetworkError> in
            let responses = xpubs.map { xpub in
                BitcoinChainAddressResponse(
                    accountIndex: 0,
                    address: xpub.address,
                    changeIndex: 0,
                    finalBalance: 0,
                    nTx: 0,
                    totalReceived: 0,
                    totalSent: 0
                )
            }
            return .just(
                BitcoinChainMultiAddressData(
                    addresses: responses,
                    latestBlockHeight: 0
                )
            )
        }

        let mockClient = APIClientMock()
        mockClient.underlyingUnspentOutputs = .just(UnspentOutputsResponse(unspent_outputs: []))
        let mockUnspentOutputRepo = UnspentOutputRepository(client: mockClient, coin: .bitcoin)

        let receiveAddressProviderMock = BitcoinChainReceiveAddressProvider<BitcoinToken>(
            mnemonicProvider: mockMnemonicProvider,
            fetchMultiAddressFor: mockFetchMultiAddressFor,
            unspentOutputRepository: mockUnspentOutputRepo
        )

        let syncPubKeysProvider = SyncPubKeysAddressesProvider(
            addressProvider: receiveAddressProviderMock,
            mnemonicProvider: mockMnemonicProvider,
            fetchMultiAddressFor: mockFetchMultiAddressFor
        )

        let expectation = expectation(description: "sync pub keys addresses")

        let activeAddresses: [String] = ["some_address_1", "some_address_2"]
        let accounts: [Account] = [
            Account(
                index: 0,
                label: "",
                archived: false,
                defaultDerivation: .segwit,
                derivations: []
            )
        ]

        // we expect 10 addresses from the currect receive index, which for this test is `0`
        let expectedGeneratedAddresses = [
            "bc1qcr8te4kr609gcawutmrza0j4xv80jy8z306fyu",
            "bc1qnjg0jd8228aq7egyzacy8cys3knf9xvrerkf9g",
            "bc1qp59yckz4ae5c4efgw2s5wfyvrz0ala7rgvuz8z",
            "bc1qgl5vlg0zdl7yvprgxj9fevsc6q6x5dmcyk3cn3",
            "bc1qm97vqzgj934vnaq9s53ynkyf9dgr05rargr04n",
            "bc1qnpzzqjzet8gd5gl8l6gzhuc4s9xv0djt0rlu7a",
            "bc1qtet8q6cd5vqm0zjfcfm8mfsydju0a29ggqrmu9",
            "bc1qhxgzmkmwvrlwvlfn4qe57lx2qdfg8phycnsarn",
            "bc1qncdts3qm2guw3hjstun7dd6t3689qg4230jh2n",
            "bc1qgswpjzsqgrm2qkfkf9kzqpw6642ptrgzapvh9y"
        ]

        let expectedAddresses = (activeAddresses + expectedGeneratedAddresses).joined(separator: "|")

        Just(())
            .subscribe(on: queue)
            .flatMap { _ -> AnyPublisher<String, SyncPubKeysAddressesProviderError> in
                syncPubKeysProvider
                    .provideAddresses(
                        active: activeAddresses,
                        accounts: accounts
                    )
            }
            .sink(
                receiveCompletion: { completion in
                    guard case .failure = completion else {
                        return
                    }
                    XCTFail("should provide correct value")
                },
                receiveValue: { addresses in
                    XCTAssertEqual(addresses, expectedAddresses)
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 10)
    }

    func test_provides_correct_addresses_for_syncing_a_different_multiAddress_index() {
        let mockMnemonicProvider: WalletMnemonicProvider = { () -> AnyPublisher<BitcoinChainKit.Mnemonic, Error> in
            .just(
                BitcoinChainKit.Mnemonic(
                    words: "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about"
                )
            )
        }

        let mockFetchMultiAddressFor: FetchMultiAddressFor = { xpubs -> AnyPublisher<BitcoinChainMultiAddressData, NetworkError> in
            let responses = xpubs.map { xpub in
                BitcoinChainAddressResponse(
                    accountIndex: 10,
                    address: xpub.address,
                    changeIndex: 0,
                    finalBalance: 0,
                    nTx: 0,
                    totalReceived: 0,
                    totalSent: 0
                )
            }
            return .just(
                BitcoinChainMultiAddressData(
                    addresses: responses,
                    latestBlockHeight: 0
                )
            )
        }

        let mockClient = APIClientMock()
        mockClient.underlyingUnspentOutputs = .just(UnspentOutputsResponse(unspent_outputs: []))
        let mockUnspentOutputRepo = UnspentOutputRepository(client: mockClient, coin: .bitcoin)

        let receiveAddressProviderMock = BitcoinChainReceiveAddressProvider<BitcoinToken>(
            mnemonicProvider: mockMnemonicProvider,
            fetchMultiAddressFor: mockFetchMultiAddressFor,
            unspentOutputRepository: mockUnspentOutputRepo
        )

        let syncPubKeysProvider = SyncPubKeysAddressesProvider(
            addressProvider: receiveAddressProviderMock,
            mnemonicProvider: mockMnemonicProvider,
            fetchMultiAddressFor: mockFetchMultiAddressFor
        )

        let expectation = expectation(description: "sync pub keys addresses")

        let activeAddresses: [String] = ["some_address_1", "some_address_2"]
        let accounts: [Account] = [
            Account(
                index: 0,
                label: "",
                archived: false,
                defaultDerivation: .segwit,
                derivations: []
            )
        ]

        // we expect 10 addresses from the currect receive index, which for this test is `0`
        let expectedGeneratedAddresses = [
            "bc1qd30z5a5e50jtgx28rvt64483tq65r9pkj623wh",
            "bc1qxr4fjkvnxjqphuyaw5a08za9g6qqh65t8qwgum",
            "bc1q8txvqq8kr0nhkatkrmeg7zaj45zpsef2ylc9pq",
            "bc1qgr7f3jfuzhpe45h3dnqxxjr3ml0de4ad2w3ysd",
            "bc1q4fxs7lhw70m7nn7u6hqsa0glyt045ls5vdl6hs",
            "bc1qgtus5u58avcs5ehpqvcllv5f66dneznw3upy2v",
            "bc1q7kv2wwzgh2zej88ywrjvnpvmqy2emefc8ar3za",
            "bc1qrz46a4gt0sghvvyt4gy5kp2rswmhtufv6sdq9v",
            "bc1qf60uv69k0prrdxkpmh94u9cwmkpkl0t0r02hgh",
            "bc1q27yd7vz8m5kz230wuyncfe3pyazez6ah58yzy0"
        ]

        let expectedAddresses = (activeAddresses + expectedGeneratedAddresses).joined(separator: "|")

        Just(())
            .subscribe(on: queue)
            .flatMap { _ -> AnyPublisher<String, SyncPubKeysAddressesProviderError> in
                syncPubKeysProvider
                    .provideAddresses(
                        active: activeAddresses,
                        accounts: accounts
                    )
            }
            .sink(
                receiveCompletion: { completion in
                    guard case .failure = completion else {
                        return
                    }
                    XCTFail("should provide correct value")
                },
                receiveValue: { addresses in
                    XCTAssertEqual(addresses, expectedAddresses)
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 10)
    }

    func test_provides_correct_addresses_for_syncing_multiple_accounts() {
        let mockMnemonicProvider: WalletMnemonicProvider = { () -> AnyPublisher<BitcoinChainKit.Mnemonic, Error> in
            .just(
                BitcoinChainKit.Mnemonic(
                    words: "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about"
                )
            )
        }

        let mockFetchMultiAddressFor: FetchMultiAddressFor = { xpubs -> AnyPublisher<BitcoinChainMultiAddressData, NetworkError> in
            let responses = xpubs.map { xpub in
                BitcoinChainAddressResponse(
                    accountIndex: 0,
                    address: xpub.address,
                    changeIndex: 0,
                    finalBalance: 0,
                    nTx: 0,
                    totalReceived: 0,
                    totalSent: 0
                )
            }
            return .just(
                BitcoinChainMultiAddressData(
                    addresses: responses,
                    latestBlockHeight: 0
                )
            )
        }

        let mockClient = APIClientMock()
        mockClient.underlyingUnspentOutputs = .just(UnspentOutputsResponse(unspent_outputs: []))
        let mockUnspentOutputRepo = UnspentOutputRepository(client: mockClient, coin: .bitcoin)

        let receiveAddressProviderMock = BitcoinChainReceiveAddressProvider<BitcoinToken>(
            mnemonicProvider: mockMnemonicProvider,
            fetchMultiAddressFor: mockFetchMultiAddressFor,
            unspentOutputRepository: mockUnspentOutputRepo
        )

        let syncPubKeysProvider = SyncPubKeysAddressesProvider(
            addressProvider: receiveAddressProviderMock,
            mnemonicProvider: mockMnemonicProvider,
            fetchMultiAddressFor: mockFetchMultiAddressFor
        )

        let expectation = expectation(description: "sync pub keys addresses")

        let activeAddresses: [String] = ["some_address_1", "some_address_2"]
        let accounts: [Account] = [
            Account(
                index: 1,
                label: "",
                archived: false,
                defaultDerivation: .segwit,
                derivations: []
            ),
            Account(
                index: 2,
                label: "",
                archived: false,
                defaultDerivation: .segwit,
                derivations: []
            )
        ]

        // we expect 10 addresses from the currect receive index, which for this test is `0` with an account of index `1`
        let expectedGeneratedAddressesAccount_1 = [
            "bc1qku0qh0mc00y8tk0n65x2tqw4trlspak0fnjmfz",
            "bc1qx0tpa0ctsy5v8xewdkpf69hhtz5cw0rf5uvyj6",
            "bc1qtyhvpd5mlhuvcwhsy976ayq2ewa9pa6ljgt7z5",
            "bc1qkgq9enypv0vm7fxmfxd8yfz95vtsuwkm5mpr90",
            "bc1qr09satsldcqr08e2pclrlnx2edu7w4308ccmdl",
            "bc1q2lw3ne8d4r57pdr8x89lf7k4vv73qe98vk4evf",
            "bc1qltfh8lgjm8suax5qxmmgkklejv9z7cttnalutp",
            "bc1qgm4dqwsg5c648a0jvsw6gkwtjx5yah8cspkv9t",
            "bc1qxmt2xvluh32w60qjqq82kacsjcdqnxxpw8t2ys",
            "bc1q2xm726yx34zyytudu6529nepqyfx9eca6s6s3e"
        ]

        // we expect 10 addresses from the currect receive index, which for this test is `0` with an account of index `2`
        let expectedGeneratedAddressesAccount_2 = [
            "bc1qkljqd65ax6mdpyzm9c2r8scg8euymkfqauukae",
            "bc1qagqxq3sk9qlm393zh3qax32w5jq5jc423tqajn",
            "bc1qex9xwhzgaa95lktxp22dtgvegn2m38vw83frz8",
            "bc1qzdl22z6yd4wx92k043hy2uaa9jrtctlhm8nd4w",
            "bc1qk2guupqdxq7tztlage84nm9yx7elak647fmq8d",
            "bc1ql774upt5yseuqhaffxlgvxuyr2xlps8v87f2ts",
            "bc1qp9n8anctaqkhp2yydyykxr6pveeutj3nlsnwjy",
            "bc1qxlh2lsjhmkxytkhg966uz55nx42x69ge2k0453",
            "bc1qq7a0tssdws2yncge4agjzfx8n2rjhqfvv7smf7",
            "bc1qpww640dz05ech25s9ry8755sgg7zn4wd58axdj"
        ]

        let generatedAddresses = expectedGeneratedAddressesAccount_1 + expectedGeneratedAddressesAccount_2
        let expectedAddresses = (activeAddresses + generatedAddresses).joined(separator: "|")

        Just(())
            .subscribe(on: queue)
            .flatMap { _ -> AnyPublisher<String, SyncPubKeysAddressesProviderError> in
                syncPubKeysProvider
                    .provideAddresses(
                        active: activeAddresses,
                        accounts: accounts
                    )
            }
            .sink(
                receiveCompletion: { completion in
                    guard case .failure = completion else {
                        return
                    }
                    XCTFail("should provide correct value")
                },
                receiveValue: { addresses in
                    XCTAssertEqual(addresses, expectedAddresses)
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 10)
    }
}
