//
//  BeneficiariesServiceUpdater.swift
//  BuySellKit
//
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import RxCocoa
import RxSwift

public protocol BeneficiariesServiceUpdaterAPI {
    /// Streams `true` or `false` values that determines if the service needs to update its underlying value
    var shouldRefresh: Observable<Bool> { get }

    /// Marks the service for update
    func markForRefresh()

    /// Resets the updater state
    func reset()
}

final class BeneficiariesServiceUpdater: BeneficiariesServiceUpdaterAPI {

    let shouldRefresh: Observable<Bool>

    private let shouldRefreshRelay = BehaviorRelay<Bool>(value: false)

    init() {
        self.shouldRefresh = shouldRefreshRelay
            .asObservable()
            .share(replay: 1, scope: .whileConnected)
    }

    func markForRefresh() {
        shouldRefreshRelay.accept(true)
    }

    func reset() {
        shouldRefreshRelay.accept(false)
    }
}
