// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MoneyKit
import PlatformKit
import SwiftUI
import ToolKit

final class TargetAuxiliaryViewPresenter: AuxiliaryViewPresenting {

    private weak var delegate: AuxiliaryViewPresentingDelegate?
    private let transactionState: TransactionState
    private let eventsRecorder: Recording

    init(
        delegate: AuxiliaryViewPresentingDelegate?,
        transactionState: TransactionState,
        eventsRecorder: Recording
    ) {
        self.delegate = delegate
        self.transactionState = transactionState
        self.eventsRecorder = eventsRecorder
    }

    func makeViewController() -> UIViewController {
        guard let account = transactionState.destination as? CryptoAccount else {
            if transactionState.destination as? CryptoAccount == nil {
                let error = "\(type(of: self)) - Invalid destination"
                eventsRecorder.record(error)
                ProbabilisticRunner.run(for: .tenPercent) {
                    fatalError(error)
                }
            }
            // return a placeholder (same view but redacted, so no info is visible, just placeholder 'boxes')
            return UIHostingController(
                rootView: TargetAccountAuxiliaryView(
                    asset: .bitcoin,
                    action: { [weak self] in
                        self?.handleTap()
                    }
                )
                .redacted(reason: .placeholder)
            )
        }

        return UIHostingController(
            rootView: TargetAccountAuxiliaryView(
                asset: account.asset,
                action: { [weak self] in
                    self?.handleTap()
                }
            )
        )
    }

    private func handleTap() {
        delegate?.auxiliaryViewTapped(self, state: transactionState)
    }
}
