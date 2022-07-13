// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ToolKit

final class MnemonicAccessProvider: MnemonicAccessAPI {
    var mnemonic: AnyPublisher<Mnemonic, MnemonicAccessError> {
        nativeWalletFeatureFlag()
            .flatMap { [legacyProvider, nativeProvider] isEnabled -> AnyPublisher<Mnemonic, MnemonicAccessError> in
                guard isEnabled else {
                    return legacyProvider.mnemonic
                }
                return nativeProvider.mnemonic
            }
            .eraseToAnyPublisher()
    }

    var mnemonicPromptingIfNeeded: AnyPublisher<Mnemonic, MnemonicAccessError> {
        nativeWalletFeatureFlag()
            .flatMap { [legacyProvider, nativeProvider] isEnabled -> AnyPublisher<Mnemonic, MnemonicAccessError> in
                guard isEnabled else {
                    return legacyProvider.mnemonicPromptingIfNeeded
                }
                return nativeProvider.mnemonicPromptingIfNeeded
            }
            .eraseToAnyPublisher()
    }

    private let legacyProvider: LegacyMnemonicAccessAPI
    private let nativeProvider: NativeMnemonicAccessAPI
    private let nativeWalletFeatureFlag: () -> AnyPublisher<Bool, Never>

    init(
        legacyProvider: LegacyMnemonicAccessAPI,
        nativeProvider: NativeMnemonicAccessAPI,
        nativeWalletFeatureFlag: @escaping () -> AnyPublisher<Bool, Never>
    ) {
        self.legacyProvider = legacyProvider
        self.nativeProvider = nativeProvider
        self.nativeWalletFeatureFlag = nativeWalletFeatureFlag
    }

    func mnemonic(with secondPassword: String?) -> AnyPublisher<Mnemonic, MnemonicAccessError> {
        nativeWalletFeatureFlag()
            .flatMap { [legacyProvider, nativeProvider] isEnabled -> AnyPublisher<Mnemonic, MnemonicAccessError> in
                guard isEnabled else {
                    return legacyProvider.mnemonic(with: secondPassword)
                }
                return nativeProvider.mnemonic(with: secondPassword)
            }
            .eraseToAnyPublisher()
    }
}
