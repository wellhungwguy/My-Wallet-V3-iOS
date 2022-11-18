// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import PlatformKit
import RIBs
import RxCocoa
import RxDataSources
import RxRelay
import RxSwift
import ToolKit
import UIComponentsKit
import UIKit

public protocol AccountPickerViewControllable: ViewControllable {
    var shouldOverrideNavigationEffects: Bool { get set }

    func connect(state: Driver<AccountPickerPresenter.State>) -> Driver<AccountPickerInteractor.Effects>
}
