// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import ComposableArchitecture
import DIKit
import Extensions
import FeatureProveDomain
import Foundation
import SwiftUI

public final class ProveRouter: ProveRouterAPI {

    private let topMostViewControllerProvider: TopMostViewControllerProviding
    private let app: AppProtocol

    public init(
        topMostViewControllerProvider: TopMostViewControllerProviding,
        app: AppProtocol = resolve()
    ) {
        self.topMostViewControllerProvider = topMostViewControllerProvider
        self.app = app
    }

    public func presentProveFlow(
    ) -> AnyPublisher<VerificationResult, Never> {
        Deferred {
            Future { [weak self] promise in

                guard let self else { return }

                let presenter = self.topMostViewControllerProvider.topMostViewController

                let view = BeginVerificationView(store: .init(
                    initialState: .init(),
                    reducer: BeginVerification(
                        app: self.app,
                        mobileAuthInfoService: resolve(),
                        dismissFlow: { result in
                            presenter?.dismiss(animated: true) {
                                promise(.success(result))
                            }
                        }
                    )
                )).app(self.app)

                presenter?.present(UIHostingController(rootView: view), animated: true)
            }
        }.eraseToAnyPublisher()
    }
}
