// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MoneyKit
import PlatformUIKit

public typealias PricesCustomSelectionActionClosure = (CryptoCurrency) -> Void

public final class PricesViewControllerProvider {
    public init() {}
    public func create(
        drawerRouter: DrawerRouting,
        showSupportedPairsOnly: Bool,
        customSelectionActionClosure: PricesCustomSelectionActionClosure? = nil
    ) -> BaseScreenViewController {
        PricesViewController(
            presenter: PricesScreenPresenter(
                drawerRouter: drawerRouter,
                interactor: PricesScreenInteractor(
                    showSupportedPairsOnly: showSupportedPairsOnly
                )
            ),
            customSelectionActionClosure: customSelectionActionClosure
        )
    }
}
