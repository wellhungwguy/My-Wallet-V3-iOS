// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import StellarKit
import WalletPayloadKit

import FeatureAppUI

/// `MnemonicAccessAPI` is part of the `bridge` that is used when injecting the `wallet` into
/// a `WalletAccountRepository`. This is how we check if the user needs to enter their
/// secondary password if their wallet is double encrypted.
extension Wallet: LegacyMnemonicAccessAPI {
    public var mnemonicPromptingIfNeeded: AnyPublisher<Mnemonic, MnemonicAccessError> {
        let prompter: SecondPasswordPromptable = resolve()
        return prompter
            .secondPasswordIfNeeded(type: .actionRequiresPassword)
            .mapError { _ in MnemonicAccessError.generic }
            .flatMap { [weak self] secondPassword -> AnyPublisher<String, MnemonicAccessError> in
                guard let self = self else {
                    return .failure(.generic)
                }
                return self.mnemonic(with: secondPassword)
            }
            .eraseToAnyPublisher()
    }

    public func mnemonic(with secondPassword: String?) -> AnyPublisher<Mnemonic, MnemonicAccessError> {
        Just(())
            .receive(on: DispatchQueue.main)
            .flatMap { [weak self] _ -> AnyPublisher<Mnemonic, MnemonicAccessError> in
                guard let self = self else {
                    return .failure(.generic)
                }
                var secondPassword = secondPassword
                if secondPassword?.isEmpty == true {
                    secondPassword = nil
                }
                if self.needsSecondPassword(), secondPassword == nil {
                    return .failure(.generic)
                }
                guard let mnemonic = self.getMnemonic(secondPassword) else {
                    return .failure(.generic)
                }
                return .just(mnemonic)
            }
            .eraseToAnyPublisher()
    }

    public var mnemonic: AnyPublisher<Mnemonic, MnemonicAccessError> {
        Just(())
            .receive(on: DispatchQueue.main)
            .flatMap { [getMnemonic] _ -> AnyPublisher<Mnemonic, MnemonicAccessError> in
                guard let mnemonic = getMnemonic(nil) else {
                    return .failure(.generic)
                }
                return .just(mnemonic)
            }
            .eraseToAnyPublisher()
    }
}
