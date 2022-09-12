// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import PlatformKit
import WalletPayloadKit

final class MnemonicAccessMock: MnemonicAccessAPI {

    var underlyingMnemonic: AnyPublisher<Mnemonic, MnemonicAccessError> = .just("")

    var mnemonic: AnyPublisher<Mnemonic, MnemonicAccessError> {
        underlyingMnemonic
    }
}
