// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import MoneyKit
import PlatformKit
import RxCocoa
import RxSwift
import ToolKit

public protocol SendAuxiliaryViewInteractorAPI: AnyObject {
    var resetToMaxAmount: Observable<Void> { get }

    var availableBalanceContentViewInteractor: ContentLabelViewInteractorAPI { get }

    var networkFeeContentViewInteractor: ContentLabelViewInteractorAPI { get }

    var networkFeeTappedRelay: PublishRelay<Void> { get }

    var availableBalanceTappedRelay: PublishRelay<Void> { get }

    var resetToMaxAmountRelay: PublishRelay<Void> { get }

    var imageRelay: PublishRelay<ImageViewContent> { get }
}

extension SendAuxiliaryViewInteractorAPI {
    /// Streams reset to max events
    public var resetToMaxAmount: Observable<Void> {
        resetToMaxAmountRelay
            .asObservable()
    }

    /// Streams network fee tap events
    public var networkFeeTapped: Observable<Void> {
        networkFeeTappedRelay
            .asObservable()
    }

    public var availableBalanceTapped: Observable<Void> {
        availableBalanceTappedRelay
            .asObservable()
    }
}

public final class SendAuxiliaryViewInteractor: SendAuxiliaryViewInteractorAPI {

    public let availableBalanceContentViewInteractor: ContentLabelViewInteractorAPI
    public let resetToMaxAmountRelay = PublishRelay<Void>()
    public let networkFeeTappedRelay = PublishRelay<Void>()
    public let availableBalanceTappedRelay = PublishRelay<Void>()
    public let networkFeeContentViewInteractor: ContentLabelViewInteractorAPI
    public let imageRelay = PublishRelay<ImageViewContent>()

    /// Display all available balance for given `CurrencyType`.
    public convenience init(
        currencyType: CurrencyType,
        coincore: CoincoreAPI = resolve()
    ) {
        self.init(
            availableBalance: AvailableBalanceContentInteractor(
                currencyType: currencyType,
                coincore: coincore
            ),
            /// NOTE: Not used in `Withdraw` which is the only place
            /// where this initializer is called
            networkFee: EmptyNetworkFeeContentInteractor()
        )
    }

    public init(
        availableBalance: ContentLabelViewInteractorAPI,
        networkFee: ContentLabelViewInteractorAPI = EmptyNetworkFeeContentInteractor()
    ) {
        self.availableBalanceContentViewInteractor = availableBalance
        self.networkFeeContentViewInteractor = networkFee
    }
}
