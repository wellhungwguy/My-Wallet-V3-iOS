// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import DIKit
import FeatureBackupRecoveryPhraseUI
import FeatureSuperAppIntroUI
import Foundation
import SwiftUI
import UIComponentsKit

public final class SuperAppIntroObserver: Session.Observer {
    unowned let app: AppProtocol
    let topViewController: TopMostViewControllerProviding

    private var cancellables: Set<AnyCancellable> = []

    public init(
        app: AppProtocol,
        topViewController: TopMostViewControllerProviding = DIKit.resolve()
    ) {
        self.app = app
        self.topViewController = topViewController
    }

    var observers: [AnyCancellable] {
        [
            userDidSignIn
        ]
    }

    public func start() {
        for observer in observers {
            observer.store(in: &cancellables)
        }
    }

    public func stop() {
        cancellables = []
    }

    lazy var userDidSignIn = app.on(blockchain.session.event.did.sign.in)
        .receive(on: DispatchQueue.main)
        .sink(to: SuperAppIntroObserver.showSuperAppIntro(_:), on: self)

    func showSuperAppIntro(_ event: Session.Event) {
        Task {
            do {
                let superAppEnabled = try await app.get(blockchain.app.configuration.app.superapp.is.enabled, as: Bool.self)
                let appDidUpdate = try await app.get(blockchain.app.did.update, as: Bool.self)

                if superAppEnabled == true, appDidUpdate == true {
                    await MainActor.run {
                        self.presentSuperAppIntro()
                    }
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    private func presentSuperAppIntro() {
        let superAppIntroView = FeatureSuperAppIntroView(store: .init(
            initialState: .init(),
            reducer: FeatureSuperAppIntroModule.reducer,
            environment: ()
        )
    )

        topViewController.topMostViewController?.present(
            superAppIntroView,
            inNavigationController: false,
            modalPresentationStyle: UIModalPresentationStyle.fullScreen
        )
    }
}
