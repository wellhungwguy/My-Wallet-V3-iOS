// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Combine
import DIKit
import Errors
import FeatureCardPaymentDomain

/// Used to execute the order once created
public protocol OrderConfirmationServiceAPI: AnyObject {
    func confirm(
        checkoutData: CheckoutData
    ) -> AnyPublisher<CheckoutData, OrderConfirmationServiceError>
}

public enum OrderConfirmationServiceError: Error {
    case mappingError
    case applePay(ApplePayError)
    case nabu(NabuNetworkError)
}

final class OrderConfirmationService: OrderConfirmationServiceAPI {

    // MARK: - Properties

    private let analyticsRecorder: AnalyticsEventRecorderAPI
    private let client: CardOrderConfirmationClientAPI
    private let applePayService: ApplePayServiceAPI

    // MARK: - Setup

    init(
        analyticsRecorder: AnalyticsEventRecorderAPI,
        client: CardOrderConfirmationClientAPI,
        applePayService: ApplePayServiceAPI
    ) {
        self.analyticsRecorder = analyticsRecorder
        self.client = client
        self.applePayService = applePayService
    }

    func confirm(checkoutData: CheckoutData) -> AnyPublisher<CheckoutData, OrderConfirmationServiceError> {
        let orderId = checkoutData.order.identifier
        let paymentMethodId = checkoutData.order.paymentMethodId

        let confirmParams: AnyPublisher<
            (
                partner: OrderPayload.ConfirmOrder.Partner,
                paymentMethodId: String?
            ),
            OrderConfirmationServiceError
        >
        switch checkoutData.order.paymentMethod {
        case .bankAccount, .bankTransfer:
            confirmParams = .just((partner: .bank, paymentMethodId: paymentMethodId))
        case .applePay where paymentMethodId?.isEmpty ?? true,
             .card where paymentMethodId?.isEmpty ?? true:
            let amount = checkoutData.order.inputValue.displayMajorValue
            let currencyCode = checkoutData.order.inputValue.currency.code
            confirmParams = applePayService
                .getToken(
                    amount: amount,
                    currencyCode: currencyCode
                )
                .map { params -> (
                    partner: OrderPayload.ConfirmOrder.Partner,
                    paymentMethodId: String?
                ) in
                    (
                        partner: OrderPayload.ConfirmOrder.Partner.applePay(params.token),
                        paymentMethodId: params.beneficiaryId
                    )
                }
                .mapError(OrderConfirmationServiceError.applePay)
                .eraseToAnyPublisher()
        case .applePay, .card:
            confirmParams = .just((
                partner: .card(redirectURL: PartnerAuthorizationData.exitLink),
                paymentMethodId: paymentMethodId
            ))
        case .funds:
            confirmParams = .just((partner: .funds, paymentMethodId: paymentMethodId))
        }

        return confirmParams
            .flatMap { [client] params -> AnyPublisher<OrderPayload.Response, OrderConfirmationServiceError> in
                client
                    .confirmOrder(
                        with: orderId,
                        partner: params.partner,
                        paymentMethodId: params.paymentMethodId
                    )
                    .mapError(OrderConfirmationServiceError.nabu)
                    .eraseToAnyPublisher()
            }
            .map { [analyticsRecorder] response -> OrderDetails? in
                OrderDetails(recorder: analyticsRecorder, response: response)
            }
            .flatMap { details -> AnyPublisher<OrderDetails, OrderConfirmationServiceError> in
                guard let details = details else {
                    return .failure(OrderConfirmationServiceError.mappingError)
                }
                if [.failed, .expired].contains(details.state), let ux = details.ux {
                    return .failure(ux)
                }
                return .just(details)
            }
            .map { checkoutData.checkoutData(byAppending: $0) }
            .eraseToAnyPublisher()
    }
}
