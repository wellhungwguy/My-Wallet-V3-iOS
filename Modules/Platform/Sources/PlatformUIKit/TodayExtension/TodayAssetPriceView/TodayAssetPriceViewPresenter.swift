// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitectureExtensions
import PlatformKit
import RxCocoa
import RxRelay
import RxSwift

public final class TodayAssetPriceViewPresenter {

    typealias PresentationState = LoadingState<Presentation>

    struct Presentation {

        // MARK: - Properties

        /// The price of the asset
        let price: LabelContent

        /// The change
        let change: NSAttributedString

        // MARK: - Setup

        init(with value: DashboardAsset.Value.Interaction.AssetPrice) {
            let fiatPrice = value.currentPrice.toDisplayString(includeSymbol: true)
            self.price = LabelContent(
                text: fiatPrice,
                font: .systemFont(ofSize: 16.0, weight: .semibold),
                color: .white,
                accessibility: .none
            )

            self.change = value.historicalPrice
                .flatMap(Self.changeAttributeString(with:))
                ?? NSAttributedString()
        }

        private static func changeAttributeString(
            with historicalPrice: DashboardAsset.Value.Interaction.AssetPrice.HistoricalPrice
        ) -> NSAttributedString {
            let color: UIColor

            if historicalPrice.priceChange.isPositive {
                color = .positivePrice
            } else if historicalPrice.priceChange.isNegative {
                color = .negativePrice
            } else { // Zero
                color = .mutedText
            }

            let fiatChange: NSAttributedString
            let fiat = historicalPrice.priceChange.toDisplayString(includeSymbol: true)
            fiatChange = NSAttributedString(
                LabelContent(
                    text: "\(fiat) ",
                    font: .systemFont(ofSize: 12.0, weight: .semibold),
                    color: color
                )
            )

            let percentageChange: NSAttributedString
            let prefix = "("
            let suffix = ")"
            let percentage = historicalPrice.changePercentage * 100
            let percentageString = percentage.string(with: 2)
            percentageChange = NSAttributedString(
                LabelContent(
                    text: "\(prefix)\(percentageString)%\(suffix)",
                    font: .systemFont(ofSize: 12.0, weight: .semibold),
                    color: color
                )
            )

            return fiatChange + percentageChange
        }
    }

    // MARK: - Exposed Properties

    var state: Observable<PresentationState> {
        _ = setup
        return stateRelay
            .observe(on: MainScheduler.instance)
    }

    var alignment: Driver<UIStackView.Alignment> {
        alignmentRelay.asDriver()
    }

    // MARK: - Injected

    private let interactor: AssetPriceViewInteracting

    // MARK: - Private Accessors

    private lazy var setup: Void = {
        /// Map interaction state into presnetation state
        /// and bind it to `stateRelay`
        interactor.state
            .map(weak: self) { _, state -> PresentationState in
                .init(with: state)
            }
            .bindAndCatch(to: stateRelay)
            .disposed(by: disposeBag)
    }()

    private let alignmentRelay: BehaviorRelay<UIStackView.Alignment>
    private let stateRelay = BehaviorRelay<PresentationState>(value: .loading)
    private let disposeBag = DisposeBag()

    // MARK: - Setup

    public init(
        interactor: AssetPriceViewInteracting,
        alignment: UIStackView.Alignment = .fill
    ) {
        self.interactor = interactor
        self.alignmentRelay = BehaviorRelay<UIStackView.Alignment>(value: alignment)
    }
}

extension LoadingState where Content == TodayAssetPriceViewPresenter.Presentation {
    init(with state: LoadingState<DashboardAsset.Value.Interaction.AssetPrice>) {
        switch state {
        case .loading:
            self = .loading
        case .loaded(next: let content):
            self = .loaded(
                next: .init(
                    with: content
                )
            )
        }
    }
}
