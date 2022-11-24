// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitectureExtensions
import PlatformKit
import PlatformUIKit
import RxRelay
import RxSwift

final class UpdateMobileScreenSetupInteractor {

    typealias BadgeItem = BadgeAsset.Value.Interaction.BadgeItem

    struct InteractionModel {
        let badgeItem: BadgeItem
        let isSMSVerified: Bool
        let is2FAEnabled: Bool
        let mobileNumber: String?

        init(badgeItem: BadgeItem, is2FAEnabled: Bool, isSMSVerified: Bool, mobileNumber: String? = nil) {
            self.badgeItem = badgeItem
            self.is2FAEnabled = is2FAEnabled
            self.isSMSVerified = isSMSVerified
            self.mobileNumber = mobileNumber
        }
    }

    typealias InteractionState = LoadingState<InteractionModel>

    var state: Observable<InteractionState> {
        stateRelay.asObservable()
    }

    let setupTrigger = PublishRelay<Void>()

    // MARK: - Private Accessors

    private let serviceAPI: SettingsServiceAPI
    private let stateRelay = BehaviorRelay<InteractionState>(value: .loading)
    private let disposeBag = DisposeBag()

    init(service: SettingsServiceAPI) {
        self.serviceAPI = service
        setupTrigger
            .bindAndCatch(weak: self) { (self) in
                self.setup()
            }
            .disposed(by: disposeBag)
        setupTrigger.accept(())
    }

    private func setup() {
        serviceAPI
            .valueObservable
            .map {
                InteractionModel(
                    badgeItem: $0.isSMSVerified ? .verified : .unverified,
                    is2FAEnabled: $0.authenticator == .sms,
                    isSMSVerified: $0.isSMSVerified,
                    mobileNumber: $0.smsNumber ?? ""
                )
            }
            .map { .loaded(next: $0) }
            .catchAndReturn(.loading)
            .startWith(.loading)
            .bindAndCatch(to: stateRelay)
            .disposed(by: disposeBag)
    }
}
