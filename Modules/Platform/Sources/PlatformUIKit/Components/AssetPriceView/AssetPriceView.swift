// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxCocoa
import RxSwift

public final class AssetPriceView: UIView {

    // MARK: - Injected

    public var presenter: AssetPriceViewPresenter! {
        willSet {
            disposeBag = DisposeBag()
        }
        didSet {
            guard let presenter else {
                priceLabel.text = " "
                changeLabel.text = " "
                return
            }
            presenter.alignment
                .drive(stackView.rx.alignment)
                .disposed(by: disposeBag)

            presenter.state
                .compactMap(\.value)
                .bindAndCatch(to: rx.values)
                .disposed(by: disposeBag)

            presenter.state
                .filter(\.isLoading)
                .mapToVoid()
                .bind { [weak self] in
                    self?.startShimmering()
                }
                .disposed(by: disposeBag)

            presenter.state
                .filter { !$0.isLoading }
                .mapToVoid()
                .bind { [weak self] in
                    self?.stopShimmering()
                }
                .disposed(by: disposeBag)
        }
    }

    // MARK: - IBOutlet Properties

    fileprivate let priceLabel = UILabel(frame: .zero)
    fileprivate let changeLabel = UILabel(frame: .zero)
    private let stackView = UIStackView(frame: .zero)

    fileprivate var priceLabelShimmeringView: ShimmeringView!
    fileprivate var changeLabelShimmeringView: ShimmeringView!

    private var disposeBag = DisposeBag()

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        priceLabel.frame = .init(origin: .zero, size: frame.size)
        changeLabel.frame = .init(origin: .zero, size: frame.size)
        stackView.frame = .init(origin: .zero, size: frame.size)
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.spacing = 4
        priceLabel.text = " "
        changeLabel.text = " "
        priceLabel.contentHuggingPriority = (.required, .required)
        priceLabel.contentCompressionResistancePriority = (.required, .required)
        changeLabel.contentHuggingPriority = (.required, UILayoutPriority(251))
        changeLabel.contentCompressionResistancePriority = (.required, .defaultHigh)
        addSubview(stackView)
        stackView.layoutToSuperview(.leading, .trailing, .top, .bottom)
        stackView.addArrangedSubview(priceLabel)
        stackView.addArrangedSubview(changeLabel)
        setNeedsLayout()
        layoutIfNeeded()
    }

    /// Should be called once when the parent view loads
    public func shimmer(
        estimatedPriceLabelSize: CGSize,
        estimatedChangeLabelSize: CGSize
    ) {
        priceLabelShimmeringView = ShimmeringView(
            in: self,
            anchorView: priceLabel,
            size: estimatedPriceLabelSize
        )
        changeLabelShimmeringView = ShimmeringView(
            in: self,
            anchorView: changeLabel,
            size: estimatedChangeLabelSize
        )
    }

    private func stopShimmering() {
        guard priceLabelShimmeringView.isShimmering, changeLabelShimmeringView.isShimmering else { return }

        changeLabel.alpha = 0
        priceLabel.alpha = 0

        let animation = {
            self.priceLabel.alpha = 1
            self.changeLabel.alpha = 1
            self.priceLabelShimmeringView.stop()
            self.changeLabelShimmeringView.stop()
        }

        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            options: [.curveEaseInOut, .transitionCrossDissolve],
            animations: animation
        )
    }

    private func startShimmering() {
        guard priceLabel.content.isEmpty else { return }
        guard changeLabel.content.isEmpty else { return }
        priceLabelShimmeringView.start()
        changeLabelShimmeringView.start()
    }
}

// MARK: - Rx

extension Reactive where Base: AssetPriceView {
    var values: Binder<DashboardAsset.Value.Presentation.AssetPrice> {
        Binder(base) { view, values in
            view.priceLabel.content = values.price
            view.changeLabel.attributedText = values.change
            view.changeLabel.accessibility = values.changeAccessibility
        }
    }
}
