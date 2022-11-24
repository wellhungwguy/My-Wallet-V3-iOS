// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import PlatformKit
import PlatformUIKit
import RxDataSources
import ToolKit

struct TargetSelectionPageCellItem: Equatable, IdentifiableType {

    // MARK: - Properties

    enum Presenter: Equatable {
        case radioSelection(RadioAccountCellPresenter)
        case cardView(TargetSelectionCardModel)
        case singleAccount(AccountCurrentBalanceCellPresenter)
        case walletInputField(TextFieldViewModel)
    }

    enum Interactor: Equatable {
        case singleAccountAvailableTarget(RadioAccountCellInteractor)
        case singleAccount(SingleAccount, AssetBalanceViewInteracting)
        case walletInputField(SingleAccount, TextFieldViewModel)

        var account: SingleAccount {
            switch self {
            case .singleAccountAvailableTarget(let interactor):
                return interactor.account
            case .singleAccount(let account, _):
                return account
            case .walletInputField(let account, _):
                return account
            }
        }

        var isWalletInputField: Bool {
            switch self {
            case .walletInputField:
                return true
            case .singleAccount,
                 .singleAccountAvailableTarget:
                return false
            }
        }

        static func == (lhs: Interactor, rhs: Interactor) -> Bool {
            lhs.account.identifier == rhs.account.identifier
        }
    }

    var isSelectable: Bool {
        switch presenter {
        case .radioSelection:
            return true
        case .singleAccount,
             .walletInputField,
             .cardView:
            return false
        }
    }

    var identity: AnyHashable {
        switch presenter {
        case .cardView(let viewModel):
            return viewModel.identifier
        case .walletInputField:
            // we currently only support one text field
            return "wallet-input"
        case .radioSelection(let presenter):
            return presenter.identity
        case .singleAccount:
            guard let account else {
                fatalError("Expected an account")
            }
            return account.identifier
        }
    }

    let account: BlockchainAccount?
    let presenter: Presenter

    init(cardView: TargetSelectionCardModel) {
        self.account = nil
        self.presenter = .cardView(cardView)
    }

    init(interactor: Interactor, assetAction: AssetAction) {
        switch interactor {
        case .singleAccountAvailableTarget(let interactor):
            self.account = interactor.account
            self.presenter = .radioSelection(
                RadioAccountCellPresenter(
                    interactor: interactor,
                    accessibilityPrefix: assetAction.accessibilityPrefix
                )
            )
        case .singleAccount(let account, let interactor):
            self.account = account
            self.presenter = .singleAccount(
                AccountCurrentBalanceCellPresenter(
                    account: account,
                    assetAction: assetAction,
                    interactor: interactor,
                    separatorVisibility: .hidden
                )
            )
        case .walletInputField(let account, let viewModel):
            self.account = account
            self.presenter = .walletInputField(viewModel)
        }
    }

    static func == (lhs: TargetSelectionPageCellItem, rhs: TargetSelectionPageCellItem) -> Bool {
        lhs.identity == rhs.identity
    }
}
