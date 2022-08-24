// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import Localization

struct ButtonAction: Equatable {

    let title: String
    let icon: Icon
    let event: L
    var disabled: Bool

    mutating func set(disabled: Bool) {
        self.disabled = disabled
    }

    static func buy(disabled: Bool) -> ButtonAction {
        ButtonAction(
            title: LocalizationConstants.Coin.Button.Title.buy,
            icon: Icon.plus,
            event: blockchain.ux.asset.buy,
            disabled: false
        )
    }

    static func send(disabled: Bool) -> ButtonAction {
        ButtonAction(
            title: LocalizationConstants.Coin.Button.Title.send,
            icon: Icon.upload,
            event: blockchain.ux.asset.send,
            disabled: disabled
        )
    }

    static func receive(disabled: Bool) -> ButtonAction {
        ButtonAction(
            title: LocalizationConstants.Coin.Button.Title.receive,
            icon: Icon.download,
            event: blockchain.ux.asset.receive,
            disabled: false
        )
    }

    static func sell(disabled: Bool) -> ButtonAction {
        ButtonAction(
            title: LocalizationConstants.Coin.Button.Title.sell,
            icon: Icon.minus,
            event: blockchain.ux.asset.sell,
            disabled: disabled
        )
    }

    static func swap(disabled: Bool) -> ButtonAction {
        ButtonAction(
            title: LocalizationConstants.Coin.Button.Title.swap,
            icon: Icon.swap,
            event: blockchain.ux.asset.account.swap,
            disabled: disabled
        )
    }
}
