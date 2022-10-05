// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// `SettingsAsyncPresenting` is used in a few presenters in `SettingsScreenPresenter`
/// (e.g. `BadgeCellPresenting`). If the cell is loading, the `SettingsScreenAction` that
/// is returned should be `.none`
protocol AsyncPresenting {
    var isLoading: Bool { get }
}
