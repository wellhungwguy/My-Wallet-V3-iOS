// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import Foundation
import PassKit

final class ApplePayAuthorizationService: NSObject, ApplePayAuthorizationServiceAPI {

    private var paymentAuthorizationController: PKPaymentAuthorizationController?

    private var tokenSubject = PassthroughSubject<Result<ApplePayToken, ApplePayError>, Never>()

    func getToken(
        amount: Decimal,
        currencyCode: String,
        info: ApplePayInfo
    ) -> AnyPublisher<ApplePayToken, ApplePayError> {
        tokenSubject = PassthroughSubject<Result<ApplePayToken, ApplePayError>, Never>()
        return tokenSubject
            .handleEvents(receiveSubscription: { [weak self] _ in
                guard let self = self else { return }
                let paymentAuthorizationController = paymentController(
                    request: paymentRequest(
                        amount: amount,
                        currencyCode: currencyCode,
                        info: info
                    ),
                    delegate: self
                )
                paymentAuthorizationController.present(completion: { [weak self] presented in
                    guard !presented else { return }
                    self?.tokenSubject.send(.failure(.invalidInputParameters))
                })
                self.paymentAuthorizationController = paymentAuthorizationController
            })
            .flatMap { result -> AnyPublisher<ApplePayToken, ApplePayError> in
                result.publisher.eraseToAnyPublisher()
            }
            .first()
            .eraseToAnyPublisher()
    }
}

private func paymentController(
    request: PKPaymentRequest,
    delegate: PKPaymentAuthorizationControllerDelegate
) -> PKPaymentAuthorizationController {
    let controller = PKPaymentAuthorizationController(
        paymentRequest: request
    )
    controller.delegate = delegate
    return controller
}

private func paymentRequest(
    amount: Decimal,
    currencyCode: String,
    info: ApplePayInfo
) -> PKPaymentRequest {
    let paymentRequest = PKPaymentRequest()

    paymentRequest.currencyCode = currencyCode
    paymentRequest.countryCode = info.merchantBankCountryCode

    paymentRequest.merchantIdentifier = info.applePayMerchantID
    paymentRequest.supportedNetworks = [.visa, .masterCard]
    paymentRequest.merchantCapabilities = info.capabilities
    paymentRequest.paymentSummaryItems = [
        PKPaymentSummaryItem(
            label: "Blockchain.com",
            amount: amount as NSDecimalNumber
        )
    ]

    return paymentRequest
}

extension ApplePayAuthorizationService: PKPaymentAuthorizationControllerDelegate {
    func paymentAuthorizationControllerDidFinish(_ controller: PKPaymentAuthorizationController) {
        controller.dismiss { [tokenSubject] in
            tokenSubject.send(.failure(.cancelled))
        }
    }

    func paymentAuthorizationController(
        _ controller: PKPaymentAuthorizationController,
        didAuthorizePayment payment: PKPayment,
        handler completion: @escaping (PKPaymentAuthorizationResult) -> Void
    ) {
        guard let token = ApplePayToken(token: payment.token) else {
            completion(.init(status: .failure, errors: [ApplePayError.invalidTokenParameters]))
            tokenSubject.send(.failure(.invalidTokenParameters))
            return
        }

        tokenSubject.send(.success(token))
        completion(.init(status: .success, errors: nil))
    }
}

extension ApplePayInfo {

    var capabilities: PKMerchantCapability {
        guard let allowCreditCards = allowCreditCards, allowCreditCards else {
            return [.capability3DS, .capabilityDebit]
        }
        return [.capability3DS, .capabilityDebit, .capabilityCredit]
    }
}
