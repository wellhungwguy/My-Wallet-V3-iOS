// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BitcoinChainKit
import Combine
import Errors
import Foundation
import WalletPayloadKit

final class UsedAccountsFinder: UsedAccountsFinderAPI {

    typealias InnerFindingResult = (xpubs: [[XPub]], accounts: [Account])
    typealias CurrentIndexAndResult = (currentIndex: UInt, result: InnerFindingResult)

    struct Account: Equatable {
        let address: String
        let nTx: Int
    }

    private let client: APIClientAPI

    private let searchIndexSubject = CurrentValueSubject<UInt, Never>(0)

    init(client: APIClientAPI) {
        self.client = client
    }

    /// When importing a wallet from a master seed (mnemonic) we need to check for the number of accounts
    /// that have been used which is inferred by the number of transactions for each account.
    ///
    /// The discovery of accounts is as follows:
    ///  1. Generate a range, starting with zero up to a given batch size `0 ..< batchSize`
    ///  2. Create xpub groups (legacy, bech32) for each index in the range
    ///  3. Fetch the addresses from the backend
    ///  4. Scan addresses in the batch range for transactions
    ///  5. In case we have transactions for all addresses in a given range, increase the index and go to step 1.
    ///  6. In case we have no or some transactions
    ///     6.1 If there are some transactions calculate the number of accounts
    ///  7. Return the total number of accounts
    ///
    func findUsedAccounts(
        batch: UInt,
        xpubRetriever: @escaping XpubRetriever
    ) -> AnyPublisher<Int, UsedAccountsFinderError> {
        searchIndexSubject
            .flatMap { [search, xpubRetriever] index -> AnyPublisher<CurrentIndexAndResult, UsedAccountsFinderError> in
                search(index, batch, xpubRetriever)
                    .map { value -> CurrentIndexAndResult in
                        (index, value)
                    }
                    .eraseToAnyPublisher()
            }
            .map { value -> (totalAccounts: Int, stopSearch: Bool) in
                // create an array of `Bool` where `true` we have transactions in an address, otherwise false
                let accounts = value.result.xpubs.map { xpub in
                    searchAccounts(xpubGroup: xpub, accounts: value.result.accounts)
                }
                if accounts.allSatisfy({ $0 }) {
                    // we found that all accounts in the current batch are used,
                    // update the batch range and restart the process
                    return (accounts.count, false)
                } else {
                    // we found that there are no or some transactions
                    // calculate the accounts to be added if any and stop the process
                    let accountsLeftToAdd = accounts.lastIndex(where: { $0 }) ?? 0
                    let adjusted = accountsLeftToAdd == 0 ? 0 : accountsLeftToAdd + 1
                    return (adjusted, true)
                }
            }
            .handleEvents(receiveOutput: { [searchIndexSubject] _, stopSearch in
                // send `finished` to subject to stop the discovery otherwise increase the index and retry
                if stopSearch {
                    searchIndexSubject.send(completion: .finished)
                } else {
                    searchIndexSubject.send(searchIndexSubject.value + 1)
                }
            })
            .map(\.totalAccounts)
            .collect()
            .map { values in
                // calculate the total accounts
                values.reduce(0, +)
            }
            .eraseToAnyPublisher()
    }

    /// Fetches the given xpubs for possible transcations
    /// - Parameter xpubs: A array of `XPub`
    /// - Returns: `AnyPublisher<[Account], NetworkError>`
    private func fetch(xpubs: [XPub]) -> AnyPublisher<[Account], NetworkError> {
        client.multiAddress(for: xpubs)
            .map(\.addresses)
            .map { addresses in
                addresses.map { Account(address: $0.address, nTx: $0.nTx) }
            }
            .eraseToAnyPublisher()
    }

    /// Creates  xpubs and retrieves any transactions against backend
    /// - Parameters:
    ///   - index: A `UInt` for the current range index
    ///   - batch: A `UInt` for the total batch range
    ///   - xpubRetriever: A method that creates an xpub based on type and index
    /// - Returns: An `AnyPublisher<InnerFindingResult>`
    private func search(
        index: UInt,
        batch: UInt,
        xpubRetriever: @escaping XpubRetriever
    ) -> AnyPublisher<InnerFindingResult, UsedAccountsFinderError> {
        xpubs(range: range(index: index, batch: batch), retriever: xpubRetriever)
            .flatMap { [fetch] xpubs -> AnyPublisher<InnerFindingResult, NetworkError> in
                let flattenXpubs = xpubs.reduce(into: [XPub]()) { $0 += $1 }
                return fetch(flattenXpubs)
                    .map { (xpubs, $0) }
                    .eraseToAnyPublisher()
            }
            .mapError(UsedAccountsFinderError.networkError)
            .eraseToAnyPublisher()
    }
}

/// Creates both legacy and bech32 xpub for a given range
/// - Parameters:
///   - range: A `Range<UInt>` representing the indices for the xpubs to be generated
///   - retriever: A method that creates/retrieves an xpub based on type and index
/// - Returns: A array of `XPub`.
private func xpubs(
    range: Range<UInt>,
    retriever: XpubRetriever
) -> AnyPublisher<[[XPub]], Never> {
    let value = range.map { index -> [XPub] in
        let legacyAddress = retriever(.legacy, index)
        let bech32Address = retriever(.segwit, index)
        return [
            XPub(address: legacyAddress, derivationType: .legacy),
            XPub(address: bech32Address, derivationType: .bech32)
        ]
    }
    return Just(value)
        .eraseToAnyPublisher()
}

/// Creates a range in based an index and a batch
///
/// - Parameters:
///   - index: A `UInt` value for the index of the range
///   - batch: A `UInt` value for the each batch
/// - Returns: A `Range<UInt>`
private func range(index: UInt, batch: UInt) -> Range<UInt> {
    index * batch..<(index * batch) + batch
}

/// Searchs the given xpub group against the given accounts
/// - Parameters:
///   - xpubGroup: An array of `XPub` for legacy and bech32 address of the same index
///   - accounts: An array of `UsedAccountsFinder.Account` to search for possible transactions
/// - Returns: `true` if a transaction is found, otherwise false
private func searchAccounts(
    xpubGroup: [XPub],
    accounts: [UsedAccountsFinder.Account]
) -> Bool {
    let foundTxs = xpubGroup.map { xpub -> Int in
        guard let address = accounts.first(where: { $0.address == xpub.address }) else {
            return 0
        }
        return address.nTx
    }
    return foundTxs.any(isAccountUsed)
}

/// A simple method extracted for readability
/// - returns: `true` if the given transcation value is greater than zero, otherwise false
private func isAccountUsed(_ transactions: Int) -> Bool {
    transactions > 0
}
