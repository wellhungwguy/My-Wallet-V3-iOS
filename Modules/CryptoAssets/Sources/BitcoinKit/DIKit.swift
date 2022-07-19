// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BitcoinChainKit
import DIKit
import MoneyKit
import PlatformKit
import WalletPayloadKit

extension DependencyContainer {

    // MARK: - BitcoinKit Module

    public static var bitcoinKit = module {

        single {
            BitcoinKit.APIClient() as BitcoinKit.APIClientAPI
        }

        single { BitcoinWalletAccountRepository() }

        factory { () -> BitcoinTxNoteProvider in
            let txNoteProvider: WalletTxNoteServiceAPI = DIKit.resolve()
            return bitcoinTxNoteProvider(
                txNoteProvider: txNoteProvider.note,
                bridge: DIKit.resolve(),
                nativeWalletFeatureFlagEnabled: { nativeWalletFlagEnabled() }
            )
        }

        factory { () -> BitcoinTxNoteUpdater in
            let txNoteProvider: WalletTxNoteServiceAPI = DIKit.resolve()
            return bitcoinTxNoteUpdater(
                txNoteUpdater: txNoteProvider.updateNote,
                bridge: DIKit.resolve(),
                nativeWalletFeatureFlagEnabled: { nativeWalletFlagEnabled() }
            )
        }

        factory(tag: CryptoCurrency.bitcoin) { BitcoinAsset() as CryptoAsset }

        single { BitcoinHistoricalTransactionService() as BitcoinHistoricalTransactionServiceAPI }

        factory { () -> AnyActivityItemEventDetailsFetcher<BitcoinActivityItemEventDetails> in
            AnyActivityItemEventDetailsFetcher(api: BitcoinActivityItemEventDetailsFetcher())
        }

        factory { () -> UsedAccountsFinderAPI in
            UsedAccountsFinder(
                client: DIKit.resolve()
            )
        }

        factory(tag: BitcoinChainCoin.bitcoin) { () -> BitcoinChainTransactionSigningServiceAPI in
            BitcoinTransactionSigningService()
        }

        single(tag: BitcoinChainCoin.bitcoin) {
            MultiAddressRepository<BitcoinHistoricalTransaction>(
                client: DIKit.resolve(tag: BitcoinChainCoin.bitcoin)
            )
        }

        factory(tag: BitcoinChainCoin.bitcoin) { () -> FetchMultiAddressFor in
            let repository: MultiAddressRepository<BitcoinHistoricalTransaction> =
                DIKit.resolve(tag: BitcoinChainCoin.bitcoin)
            return { xpubs in
                repository.multiAddress(for: xpubs)
                    .map {
                        BitcoinChainMultiAddressData(
                            addresses: $0.addresses,
                            latestBlockHeight: $0.latestBlockHeight
                        )
                    }
                    .eraseToAnyPublisher()
            }
        }
    }
}
