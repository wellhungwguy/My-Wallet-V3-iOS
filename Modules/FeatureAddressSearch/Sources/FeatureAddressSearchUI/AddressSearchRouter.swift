// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ComposableArchitecture
import DIKit
import FeatureAddressSearchDomain
import Foundation
import SwiftUI
import UIKitExtensions

public final class AddressSearchRouter: AddressSearchRouterAPI {

    private let topMostViewControllerProvider: TopMostViewControllerProviding
    private let addressService: AddressServiceAPI

    public init(
        topMostViewControllerProvider: TopMostViewControllerProviding,
        addressService: AddressServiceAPI
    ) {
        self.topMostViewControllerProvider = topMostViewControllerProvider
        self.addressService = addressService
    }

    public func presentSearchAddressFlow(
        prefill: Address?,
        config: AddressSearchFeatureConfig
    ) -> AnyPublisher<Address?, Never> {
        Deferred {
            Future { [weak self] promise in

                guard let self = self else { return }

                let presenter = self.topMostViewControllerProvider.topMostViewController
                let env = AddressSearchEnvironment(
                    mainQueue: .main,
                    config: config,
                    addressService: self.addressService,
                    addressSearchService: resolve(),
                    onComplete: { address in
                        presenter?.dismiss(animated: true)
                        promise(.success(address))
                    }
                )
                let view = AddressSearchView(
                    store: .init(
                        initialState: .init(address: prefill, error: nil),
                        reducer: addressSearchReducer,
                        environment: env
                    )
                )
                presenter?.present(view)
            }
        }.eraseToAnyPublisher()
    }

    public func presentEditAddressFlow(
        isPresentedWithoutSearchView: Bool,
        config: AddressSearchFeatureConfig.AddressEditScreenConfig
    ) -> AnyPublisher<Address?, Never> {
        Deferred {
            Future { [weak self] promise in

                guard let self = self else { return }

                let presenter = self.topMostViewControllerProvider.topMostViewController
                let env = AddressModificationEnvironment(
                    mainQueue: .main,
                    config: config,
                    addressService: self.addressService,
                    addressSearchService: resolve(),
                    onComplete: { address in
                        presenter?.dismiss(animated: true)
                        promise(.success(address))
                    }
                )
                let view = AddressModificationView(
                    store: .init(
                        initialState: .init(isPresentedWithoutSearchView: isPresentedWithoutSearchView),
                        reducer: addressModificationReducer,
                        environment: env
                    )
                )
                presenter?.present(view)
            }
        }.eraseToAnyPublisher()
    }
}
