// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MoneyKit
import PlatformKit

enum TargetSelectionAction: MviAction {

    case sourceAccountSelected(BlockchainAccount, AssetAction)
    case availableTargets([BlockchainAccount])
    case destinationDeselected
    case validateQRScanner(CryptoReceiveAddress)
    case validateAddress(String, BlockchainAccount)
    case destinationSelected(BlockchainAccount)
    case validateBitPayPayload(String, CryptoCurrency)
    case addressValidated(TargetSelectionInputValidation.TextInput)
    case validBitPayInvoiceTarget(BitPayInvoiceTarget)
    case destinationConfirmed
    case returnToPreviousStep
    case qrScannerButtonTapped
    case resetFlow

    func reduce(oldState: TargetSelectionPageState) -> TargetSelectionPageState {
        switch self {
        case .validateBitPayPayload:
            return oldState
        case .availableTargets(let accounts):
            return oldState
                .update(keyPath: \.availableTargets, value: accounts.compactMap { $0 as? SingleAccount })
                .withUpdatedBackstack(oldState: oldState)
        case .sourceAccountSelected(let account, _):
            return oldState
                .update(keyPath: \.sourceAccount, value: account)
                .withUpdatedBackstack(oldState: oldState)
        case .destinationSelected(let account):
            let destination = account as! TransactionTarget
            return oldState
                .update(keyPath: \.inputValidated, value: .account(.account(account)))
                .update(keyPath: \.destination, value: destination)
                .update(keyPath: \.nextEnabled, value: true)
                .withUpdatedBackstack(oldState: oldState)
        case .destinationDeselected:
            return oldState
                .update(keyPath: \.destination, value: nil)
                .update(keyPath: \.nextEnabled, value: false)
                .withUpdatedBackstack(oldState: oldState)
        case .destinationConfirmed:
            return oldState
                .update(keyPath: \.step, value: .complete)
        case .validateQRScanner(let cryptoReceiveAddress):
            return oldState
                .update(keyPath: \.inputValidated, value: .QR(.valid(cryptoReceiveAddress)))
                .update(keyPath: \.destination, value: cryptoReceiveAddress)
                .update(keyPath: \.nextEnabled, value: true)
                .withUpdatedBackstack(oldState: oldState)
        case .validateAddress(let address, _):
            return oldState
                .update(keyPath: \.inputValidated, value: .text(.invalid(address)))
        case .addressValidated(let inputValidation):
            switch inputValidation {
            case .valid(_, let receiveAddress):
                return oldState
                    .update(keyPath: \.inputValidated, value: .text(inputValidation))
                    .update(keyPath: \.destination, value: receiveAddress)
                    .update(keyPath: \.nextEnabled, value: true)
                    .withUpdatedBackstack(oldState: oldState)
            case .invalid, .inactive:
                return oldState
                    .update(keyPath: \.destination, value: nil)
                    .update(keyPath: \.inputValidated, value: .text(inputValidation))
                    .update(keyPath: \.nextEnabled, value: false)
                    .withUpdatedBackstack(oldState: oldState)
            }
        case .validBitPayInvoiceTarget(let invoice):
            return oldState
                .update(keyPath: \.destination, value: invoice)
                .update(keyPath: \.nextEnabled, value: true)
                .withUpdatedBackstack(oldState: oldState)
        case .returnToPreviousStep:
            var stepsBackStack = oldState.stepsBackStack
            let previousStep = stepsBackStack.popLast() ?? .initial
            return oldState
                .update(keyPath: \.stepsBackStack, value: stepsBackStack)
                .update(keyPath: \.step, value: previousStep)
                .update(keyPath: \.isGoingBack, value: oldState.step != .qrScanner ? true : false)
                .withUpdatedBackstack(oldState: oldState)
        case .qrScannerButtonTapped:
            return oldState
                .update(keyPath: \.inputValidated, value: .QR(.empty))
                .update(keyPath: \.step, value: .qrScanner)
                .withUpdatedBackstack(oldState: oldState)
        case .resetFlow:
            return oldState
                .update(keyPath: \.step, value: .closed)
                .withUpdatedBackstack(oldState: oldState)
        }
    }
}
