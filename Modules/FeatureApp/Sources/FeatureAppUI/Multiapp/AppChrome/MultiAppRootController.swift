//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import SwiftUI
import UIKit

public final class MultiAppRootController: UIHostingController<MultiAppContainerChrome> {

    let global: ViewStore<LoggedIn.State, LoggedIn.Action>

    public init(store global: Store<LoggedIn.State, LoggedIn.Action>) {

        self.global = ViewStore(global)
        // TODO: pass in state, this is just for demo purposes
        super.init(rootView: MultiAppContainerChrome())
    }

    @available(*, unavailable)
    @MainActor dynamic required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
