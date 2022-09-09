// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Foundation
import Localization
import MetadataKit
import ToolKit

public enum BitcoinCashFetchError: Error {
    case fetchFailure(WalletAssetFetchError)
    case saveFailure(WalletAssetSaveError)
}

/// Types adopting `BitcoinCashEntryFetcherAPI` should be able to provide entries for Bitcoin and BitcoinCash assets
public protocol BitcoinCashEntryFetcherAPI {
    /// Fetches a `BitcoinCashEntry` from Wallet metadata
    func fetchOrCreateBitcoinCash() -> AnyPublisher<BitcoinCashEntry, BitcoinCashFetchError>

    /// Updates a `BitcoinCashEntry` to wallet metadata
    /// - Parameter entry: A `BitcoinCashEntry`
    /// - Returns: `AnyPublisher<EmptyValue, BitcoinCashFetchError>`
    func update(entry: BitcoinCashEntry) -> AnyPublisher<EmptyValue, BitcoinCashFetchError>
}

final class BitcoinCashEntryFetcher: BitcoinCashEntryFetcherAPI {

    private let walletHolder: WalletHolderAPI
    private let metadataEntryService: WalletMetadataEntryServiceAPI

    init(
        walletHolder: WalletHolderAPI,
        metadataEntryService: WalletMetadataEntryServiceAPI
    ) {
        self.walletHolder = walletHolder
        self.metadataEntryService = metadataEntryService
    }

    func fetchOrCreateBitcoinCash() -> AnyPublisher<BitcoinCashEntry, BitcoinCashFetchError> {
        metadataEntryService.fetchEntry(type: BitcoinCashEntryPayload.self)
            .catch { [walletHolder, metadataEntryService] error
                -> AnyPublisher<BitcoinCashEntryPayload, BitcoinCashFetchError> in
                guard case .fetchFailed(.loadMetadataError(.notYetCreated)) = error else {
                    return .failure(.fetchFailure(error))
                }
                return generateBitcoinCashEntryPayload(
                    walletHolder: walletHolder,
                    label: LocalizationConstants.Account.myWallet
                )
                .flatMap { payload -> AnyPublisher<BitcoinCashEntryPayload, BitcoinCashFetchError> in
                    metadataEntryService.save(node: payload)
                        .map { _ in payload }
                        .mapError(BitcoinCashFetchError.saveFailure)
                        .eraseToAnyPublisher()
                }
                .eraseToAnyPublisher()
            }
            .flatMap { [walletHolder] payload -> AnyPublisher<BitcoinCashEntry, BitcoinCashFetchError> in
                provideBitcoinCashEntry(
                    walletHolder: walletHolder,
                    payload: payload
                )
            }
            .eraseToAnyPublisher()
    }

    func update(entry: BitcoinCashEntry) -> AnyPublisher<EmptyValue, BitcoinCashFetchError> {
        metadataEntryService.save(node: entry.toMetadataEntry())
            .first()
            .mapError(BitcoinCashFetchError.saveFailure)
            .eraseToAnyPublisher()
    }
}

private func fetchWallet(
    walletHolder: WalletHolderAPI
) -> AnyPublisher<NativeWallet, BitcoinCashFetchError> {
    walletHolder.walletStatePublisher
        .flatMap { state -> AnyPublisher<NativeWallet, BitcoinCashFetchError> in
            guard let wallet = state?.wallet else {
                return .failure(.fetchFailure(.notInitialized))
            }
            return .just(wallet)
        }
        .eraseToAnyPublisher()
}

/// Provides a `BitcoinCashEntry` from given `BitcoinCashEntryPayload`
/// - Parameters:
///   - walletHolder: A `WalletHolderAPI` which provides wallet state
///   - payload: A fetched `BitcoinCashEntryPayload` value
/// - Returns: `AnyPublisher<BitcoinCashEntry, WalletAssetFetchError>`
private func provideBitcoinCashEntry(
    walletHolder: WalletHolderAPI,
    payload: BitcoinCashEntryPayload
) -> AnyPublisher<BitcoinCashEntry, BitcoinCashFetchError> {
    fetchWallet(walletHolder: walletHolder)
        .map { BitcoinCashEntry(payload: payload, wallet: $0) }
        .eraseToAnyPublisher()
}

/// Generates a `BitcoinCashEntryPayload` from the current initialized wallet
/// - Note: We don't store `xpub` on metadata only the number of accounts from the default wallet
/// - Parameter walletHolder: A `WalletHolderAPI` which provides access to the wallet
/// - Returns: A `AnyPublisher<BitcoinCashEntryPayload, WalletAssetFetchError>`
private func generateBitcoinCashEntryPayload(
    walletHolder: WalletHolderAPI,
    label: String
) -> AnyPublisher<BitcoinCashEntryPayload, BitcoinCashFetchError> {
    fetchWallet(walletHolder: walletHolder)
        .map { wallet -> [BitcoinCashEntryPayload.Account] in
            let hdWalletsAccounts = wallet.defaultHDWallet?.accounts ?? []
            return hdWalletsAccounts
                .enumerated()
                .map { index, _ -> BitcoinCashEntryPayload.Account in
                    let label = index > 0 ? "\(label) \(index + 1)" : label
                    return BitcoinCashEntryPayload.Account(
                        archived: false,
                        label: label
                    )
                }
        }
        .map { accounts in
            BitcoinCashEntryPayload(
                accounts: accounts,
                defaultAccountIndex: 0,
                hasSeen: false,
                txNotes: [:],
                addresses: [:]
            )
        }
        .eraseToAnyPublisher()
}
