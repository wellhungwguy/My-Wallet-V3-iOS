// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import FeatureAuthenticationDomain
import Foundation
import MoneyKit
import NetworkKit
import ToolKit

public protocol SendEmailNotificationServiceAPI {

    func postSendEmailNotificationTrigger(
        moneyValue: MoneyValue,
        txHash: String
    ) -> AnyPublisher<Void, Never>
}

public class SendEmailNotificationService: SendEmailNotificationServiceAPI {

    private let client: SendEmailNotificationClientAPI
    private let credentialsRepository: CredentialsRepositoryAPI
    private let errorRecoder: ErrorRecording

    init(
        client: SendEmailNotificationClientAPI = resolve(),
        credentialsRepository: CredentialsRepositoryAPI = resolve(),
        errorRecoder: ErrorRecording = resolve()
    ) {
        self.client = client
        self.credentialsRepository = credentialsRepository
        self.errorRecoder = errorRecoder
    }

    public func postSendEmailNotificationTrigger(
        moneyValue: MoneyValue,
        txHash: String
    ) -> AnyPublisher<Void, Never> {
        credentialsRepository.credentials
            .ignoreFailure()
            .map { guid, sharedKey in
                let assetModel = moneyValue.currency.cryptoCurrency?.assetModel
                let network = assetModel?.kind.erc20ParentChain ?? moneyValue.code
                let amount = moneyValue.toSimpleString(includeSymbol: false)
                return SendEmailNotificationClient.Payload(
                    guid: guid,
                    sharedKey: sharedKey,
                    currency: moneyValue.code,
                    amount: amount,
                    network: network,
                    txHash: txHash
                )
            }
            .flatMap { [client] payload in
                client.postSendEmailNotificationTrigger(payload)
            }
            .handleEvents(receiveCompletion: { [errorRecoder] in
                if case .failure(let error) = $0 {
                    errorRecoder.error(error)
                }
            })
            .ignoreFailure()
            .eraseToAnyPublisher()
    }
}
