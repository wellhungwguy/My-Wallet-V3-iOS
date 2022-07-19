// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Foundation
import ToolKit

typealias PayloadHealthCheck = (_ wallet: Wrapper) -> AnyPublisher<Wrapper, WalletError>

typealias Checker = () -> String?

func walletPayloadHealthCheckProvider(
    tracer: @escaping (_ message: String) -> Void
) -> (_ wrapper: Wrapper) -> AnyPublisher<Wrapper, WalletError> {
    { [tracer] wrapper -> AnyPublisher<Wrapper, WalletError> in
        let wallet = wrapper.wallet
        let failurePoints: [Checker] = [
            hdWalletsValidity(wallet.hdWallets),
            missingDefaultHDWallet(wallet.hdWallets)
        ]

        let failurePointsHDWallet: [Checker]
        if let defaultHDWallet = wallet.defaultHDWallet {
            let seedHexCheck = seedHexValidity(defaultHDWallet.seedHex)
            let defaultAccountIndexCheck = defaultAccountIndexValidity(defaultHDWallet.defaultAccountIndex)
            let accountChecks: [Checker] = defaultHDWallet.accounts.map { account in
                accountDerivationValidity(account)
            }
            let derivationChecks: [Checker] = defaultHDWallet.accounts
                .map { account in
                    account.derivations
                        .compactMap { derivationPurposeValidity($0) }
                }
                .flatMap { $0 }

            failurePointsHDWallet = [seedHexCheck, defaultAccountIndexCheck] + accountChecks + derivationChecks
        } else {
            failurePointsHDWallet = []
        }

        let failuresChecks: [Checker] = failurePoints + failurePointsHDWallet
        let checkResults = failuresChecks.compactMap { $0() }
        for checkResult in checkResults {
            tracer(checkResult)
        }
        return .just(wrapper)
    }
}

// MARK: - Health Checks

func missingDefaultHDWallet(_ value: [HDWallet]) -> Checker {
    {
        if value.count == 0 {
            return "MISSING_DEFAULT_HD_WALLET"
        }
        return nil
    }
}

func hdWalletsValidity(_ value: [HDWallet]) -> Checker {
    {
        if value.count > 1 {
            return "MULTIPLE_HD_WALLETS"
        }
        return nil
    }
}

func seedHexValidity(_ value: String) -> Checker {
    {
        if value.count != 32 {
            return "INCORRECT_SEED_HEX_LENGTH"
        }
        return nil
    }
}

func defaultAccountIndexValidity(_ value: Int) -> Checker {
    {
        if value < 0 {
            return "INCORRECT_DEFAULT_ACCOUNT_IDX"
        }
        return nil
    }
}

func accountDerivationValidity(_ value: Account) -> Checker {
    {
        if value.derivations.count != DerivationType.allCases.count {
            return "INCORRECT_NUMBER_OF_ACCOUNT_DERIVATIONS_\(value.derivations.count)"
        }
        return nil
    }
}

func derivationPurposeValidity(_ value: Derivation) -> Checker {
    {
        let possiblePurposes = DerivationType.allCases.map(\.purpose)
        if !possiblePurposes.contains(value.purpose) {
            return "INCORRECT_DERIVATION_PURPOSE_FOUND_\(value.purpose)"
        }
        return nil
    }
}
