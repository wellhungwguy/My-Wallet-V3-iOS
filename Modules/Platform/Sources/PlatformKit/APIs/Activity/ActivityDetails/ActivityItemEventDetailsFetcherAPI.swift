// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MoneyKit
import RxRelay
import RxSwift

public protocol ActivityItemEventDetailsFetcherAPI: AnyObject {
    associatedtype Model
    func details(
        for identifier: String,
        cryptoCurrency: CryptoCurrency
    ) -> Observable<Model>
}

public struct AnyActivityItemEventDetailsFetcher<Model> {

    private let detailsObservable: (String, CryptoCurrency) -> Observable<Model>

    public init<API: ActivityItemEventDetailsFetcherAPI>(api: API) where API.Model == Model {
        self.detailsObservable = api.details
    }

    public func details(
        for identifier: String,
        cryptoCurrency: CryptoCurrency
    ) -> Observable<Model> {
        detailsObservable(identifier, cryptoCurrency)
    }
}
