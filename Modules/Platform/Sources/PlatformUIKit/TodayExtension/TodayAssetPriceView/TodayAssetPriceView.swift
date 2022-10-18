// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxCocoa
import RxSwift

public final class TodayAssetPriceView: UIView {

    // MARK: - Injected

    public var presenter: TodayAssetPriceViewPresenter! {
        willSet {
            disposeBag = DisposeBag()
        }
        didSet {
            guard let presenter else {
                return
            }
            presenter.alignment
                .drive(stackView.rx.alignment)
                .disposed(by: disposeBag)

            presenter.state
                .compactMap(\.value)
                .bindAndCatch(to: rx.values)
                .disposed(by: disposeBag)
        }
    }

    // MARK: - Private Properties

    fileprivate let priceLabel = UILabel()
    fileprivate let changeLabel = UILabel()
    private let stackView = UIStackView()
    private var disposeBag = DisposeBag()

    // MARK: - Setup

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        backgroundColor = .clear
        addSubview(stackView)
        stackView.fillSuperview()
        stackView.layout(dimension: .height, to: 32, priority: .defaultLow)
        stackView.addArrangedSubview(priceLabel)
        stackView.addArrangedSubview(changeLabel)

        stackView.distribution = .fillProportionally
        stackView.axis = .vertical
        stackView.spacing = 4.0
    }
}

// MARK: - Rx

extension Reactive where Base: TodayAssetPriceView {
    var values: Binder<TodayAssetPriceViewPresenter.Presentation> {
        Binder(base) { view, values in
            view.priceLabel.content = values.price
            view.changeLabel.attributedText = values.change
        }
    }
}
