// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import FeatureCardPaymentDomain
import PlatformKit
import PlatformUIKit
import RxSwift
import ToolKit
import UIKit

enum CardLinkingFlowResult: Equatable {
    case abandoned
    case completed(CardData)
}

/// This protocol provides an interface to present the flow to link a credit or debit card to a user's account.
///
/// This stand-alone piece is wrapping the entire flow required to link a credit or debit card to the user's account.
///
/// - IMPORTANT: Do NOT use this protocol directly. Use `PaymentMethodLinkingRouterAPI` instead!
protocol CardLinkerAPI {

    /// Presents the card linking flow modally on top of the passed-in `presenter`.
    /// - Parameters:
    ///   - presenter: The `UIViewController` that needs to present the linking flow.
    ///   - completion: A closure called when the flow is completed or dismissed.
    func presentCardLinkingFlow(
        from presenter: UIViewController,
        completion: @escaping (CardLinkingFlowResult) -> Void
    )
}

final class CardLinker: CardLinkerAPI {

    private let paymentMethodTypesService: PaymentMethodTypesServiceAPI

    private var cardRouter: CardRouter!
    private var cancellables = Set<AnyCancellable>()

    init(paymentMethodTypesService: PaymentMethodTypesServiceAPI = resolve()) {
        self.paymentMethodTypesService = paymentMethodTypesService
    }

    func presentCardLinkingFlow(
        from presenter: UIViewController,
        completion: @escaping (CardLinkingFlowResult) -> Void
    ) {
        if cardRouter != nil {
            ProbabilisticRunner.run(for: .onePercent) {
                fatalError("Attempting to present \(type(of: self)) when an instance is already in use.")
            }
            cardRouter = nil
            return
        }
        // NOTE: the presenter is currently unused because of how the `CardRouter` is implemented but it should be refactored
        let interactor = CardRouterInteractor()
        interactor
            .completionCardData
            .asPublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completionResult in
                self?.cleanUp()
                if case .failure(let error) = completionResult {
                    Logger.shared.error(error)
                    completion(.abandoned)
                }
            } receiveValue: { data in
                completion(.completed(data))
            }
            .store(in: &cancellables)

        interactor
            .cancellation
            .asPublisher()
            .replaceError(with: ())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completionResult in
                self?.cleanUp()
                if case .failure(let error) = completionResult {
                    Logger.shared.error(error)
                    completion(.abandoned)
                }
            } receiveValue: { _ in
                completion(.abandoned)
            }
            .store(in: &cancellables)

        let builder = CardComponentBuilder(
            routingInteractor: interactor,
            paymentMethodTypesService: paymentMethodTypesService
        )
        cardRouter = CardRouter(
            interactor: interactor,
            builder: builder,
            routingType: .modal
        )
        cardRouter.load()
    }

    private func cleanUp() {
        cardRouter = nil
        cancellables.removeAll()
    }
}
