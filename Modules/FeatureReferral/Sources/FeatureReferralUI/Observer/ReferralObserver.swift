// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import DIKit
import FeatureReferralDomain
import Foundation
import SwiftUI
import ToolKit
import UIComponentsKit

public final class ReferralAppObserver: Session.Observer {
    unowned let app: AppProtocol
    let referralService: ReferralServiceAPI
    let featureFlagService: FeatureFlagsServiceAPI
    let topViewController: TopMostViewControllerProviding

    private var cancellables: Set<AnyCancellable> = []

    public init(
        app: AppProtocol,
        referralService: ReferralServiceAPI,
        featureFlagService: FeatureFlagsServiceAPI,
        topViewController: TopMostViewControllerProviding = DIKit.resolve()
    ) {
        self.app = app
        self.referralService = referralService
        self.featureFlagService = featureFlagService
        self.topViewController = topViewController
    }

    var observers: [BlockchainEventSubscription] {
        [
            signIn,
            walletCreated
        ]
    }

    public func start() {
        for observer in observers {
            observer.start()
        }
    }

    public func stop() {
        for observer in observers {
            observer.stop()
        }
    }

    private lazy var referralCodePublisher = app.publisher(
        for: blockchain.user.creation.referral.code,
        as: String.self
    )
    .compactMap(\.value)

    private lazy var featureFlagPublisher = featureFlagService
        .isEnabled(.referral)

    lazy var walletCreated = app.on(blockchain.user.wallet.created) { [unowned self] _ in
        featureFlagPublisher
            .zip(referralCodePublisher)
            .filter(\.0)
            .map(\.1)
            .flatMap(referralService.createReferral(with:))
            .subscribe()
            .store(in: &cancellables)
    }

    lazy var signIn = app.on(blockchain.session.event.did.sign.in) { [unowned self] _ in
        fetchReferralCampaign()
    }

    private func fetchReferralCampaign() {
        Publishers
            .CombineLatest(
                featureFlagPublisher,
                referralService
                    .fetchReferralCampaign()
            )
            .sink(receiveValue: { [weak self] isEnabled, referralCampaign in
                guard let self = self,
                      isEnabled,
                      let referralCampaign = referralCampaign
                else {
                    self?.app.state.clear(blockchain.user.referral.campaign)
                    return
                }
                self.app.post(value: referralCampaign, of: blockchain.user.referral.campaign)
            })
            .store(in: &cancellables)
    }
}
