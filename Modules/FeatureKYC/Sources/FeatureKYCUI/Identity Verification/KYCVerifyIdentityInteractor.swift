// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import NetworkKit
import PlatformKit
import PlatformUIKit
import RxSwift

protocol KYCVerifyIdentityInput: AnyObject {
    func submitVerification(
        onCompleted: @escaping (() -> Void),
        onError: @escaping ((Error) -> Void)
    )
    func createCredentials(
        onSuccess: @escaping ((VeriffCredentials) -> Void),
        onError: @escaping ((Error) -> Void)
    )
    func supportedDocumentTypes(
        countryCode: String
    ) -> AnyPublisher<[KYCDocumentType], NabuNetworkError>
}

class KYCVerifyIdentityInteractor {
    private let loadingViewPresenter: LoadingViewPresenting

    private var cache = [String: [KYCDocumentType]]()

    private let veriffService = VeriffService()

    private let client: KYCClientAPI
    private var veriffCredentials: VeriffCredentials?

    private var disposable: Disposable?

    init(
        client: KYCClientAPI = resolve(),
        loadingViewPresenter: LoadingViewPresenting = resolve()
    ) {
        self.loadingViewPresenter = loadingViewPresenter
        self.client = client
    }

    deinit {
        disposable?.dispose()
        disposable = nil
    }
}

extension KYCVerifyIdentityInteractor: KYCVerifyIdentityInput {
    func submitVerification(
        onCompleted: @escaping (() -> Void),
        onError: @escaping ((Error) -> Void)
    ) {
        guard let credentials = veriffCredentials else { return }
        disposable = veriffService.submitVerification(applicantId: credentials.applicantId)
            .observe(on: MainScheduler.instance)
            .do(onDispose: { [weak self] in
                self?.loadingViewPresenter.hide()
            })
            .subscribe(
                onCompleted: onCompleted,
                onError: onError
            )
    }

    func createCredentials(onSuccess: @escaping ((VeriffCredentials) -> Void), onError: @escaping ((Error) -> Void)) {
        disposable = veriffService.createCredentials()
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] credentials in
                guard let this = self else { return }
                this.veriffCredentials = credentials
                onSuccess(credentials)
            }, onFailure: onError)
    }

    func supportedDocumentTypes(
        countryCode: String
    ) -> AnyPublisher<[KYCDocumentType], NabuNetworkError> {
        // Check cache
        if let types = cache[countryCode] {
            return .just(types)
        }

        return client
            .supportedDocuments(for: countryCode)
            .map { [weak self] documents in
                let documentTypes = documents.documentTypes
                self?.cache[countryCode] = documentTypes
                return documentTypes
            }
            .eraseToAnyPublisher()
    }
}
