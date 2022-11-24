// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MoneyKit
import PlatformKit
import PlatformUIKit
import RxSwift

protocol WalletActionScreenInteracting: AnyObject {
    var currency: CurrencyType { get }
    var accountType: SingleAccountType { get }
    var availableActions: Single<AvailableActions> { get }
    var balanceCellInteractor: CurrentBalanceCellInteracting { get }
}

final class WalletActionScreenInteractor: WalletActionScreenInteracting {

    var availableActions: Single<AvailableActions> {
        account
            .actions
            .asSingle()
    }

    var accountType: SingleAccountType {
        balanceCellInteractor.accountType
    }

    let currency: CurrencyType
    let balanceCellInteractor: CurrentBalanceCellInteracting

    // MARK: - Private Properties

    private let account: BlockchainAccount

    // MARK: - Init

    init(account: BlockchainAccount) {
        self.account = account
        self.currency = account.currencyType
        self.balanceCellInteractor = CurrentBalanceCellInteractor(
            account: account
        )
    }
}
