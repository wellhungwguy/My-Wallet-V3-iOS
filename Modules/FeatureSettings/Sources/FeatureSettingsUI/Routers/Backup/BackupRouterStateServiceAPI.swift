// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxRelay
import RxSwift

protocol BackupRouterStateReceiverServiceAPI: AnyObject {

    /// The action that should be executed, the `next` action
    /// is coupled with the current state
    var action: Observable<BackupRouterStateService.Action> { get }
}

protocol BackupRouterStateEmitterServiceAPI: AnyObject {

    /// Move to the next state
    var nextRelay: PublishRelay<Void> { get }

    /// Move to the previous state
    var previousRelay: PublishRelay<Void> { get }
}

/// A composition of all of Simple-Buy state-services
typealias BackupRouterStateServiceAPI = BackupRouterStateReceiverServiceAPI &
    BackupRouterStateEmitterServiceAPI

/// `Entry` denotes from where the state is being started.
/// The entry may mean controllers are presented with a different `PresentationType`.
public enum BackupRouterEntry {

    // Entering from the `Send` custody flow
    case custody

    // Entering from `Settings` which has a `NavigationController`
    case settings

    // Entering from "Defi Wallet Intro" for new MVP App 2.0 experience
    case defiIntroScreen
}
