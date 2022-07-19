// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformUIKit
import RxCocoa
import RxSwift

final class FiatBalanceView: UIView {

    // MARK: - Injected

    var presenter: FiatBalanceViewPresenter! {
        willSet {
            disposeBag = DisposeBag()
        }
        didSet {
            guard let presenter = presenter else {
                return
            }

            presenter.alignment
                .drive(stackView.rx.alignment)
                .disposed(by: disposeBag)

            presenter.state
                .compactMap(\.value)
                .drive(rx.values)
                .disposed(by: disposeBag)

            presenter.state
                .map(\.isLoading)
                .drive(weak: self) { (self, _) in
                    self.startShimmering()
                }
                .disposed(by: disposeBag)

            presenter.state
                .filter { $0.isLoading == false }
                .drive(weak: self) { (self, _) in
                    self.stopShimmering()
                }
                .disposed(by: disposeBag)
        }
    }

    // MARK: - Private IBOutlets

    private let stackView = UIStackView()
    fileprivate let baseLabel = UILabel()
    fileprivate let quoteLabel = UILabel()

    fileprivate var fiatLabelShimmeringView: ShimmeringView!
    fileprivate var baseFiatLabelShimmeringView: ShimmeringView!

    private var disposeBag = DisposeBag()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        addSubview(stackView)
        stackView.axis = .vertical
        stackView.fillSuperview()
        stackView.distribution = .fillEqually

        for view in [quoteLabel, baseLabel] {
            stackView.addArrangedSubview(view)
        }
    }

    /// Should be called once when the parent view loads
    func shimmer(estimatedFiatLabelSize: CGSize, estimatedCryptoLabelSize: CGSize) {
        fiatLabelShimmeringView = ShimmeringView(
            in: self,
            anchorView: quoteLabel,
            size: estimatedFiatLabelSize
        )
        baseFiatLabelShimmeringView = ShimmeringView(
            in: self,
            anchorView: baseLabel,
            size: estimatedCryptoLabelSize
        )
    }

    private func stopShimmering() {
        guard fiatLabelShimmeringView != nil else { return }
        guard baseFiatLabelShimmeringView != nil else { return }
        guard fiatLabelShimmeringView.isShimmering, baseFiatLabelShimmeringView.isShimmering else { return }

        baseLabel.alpha = 0
        quoteLabel.alpha = 0

        let animation = {
            self.baseLabel.alpha = 1
            self.quoteLabel.alpha = 1
            self.fiatLabelShimmeringView.stop()
            self.baseFiatLabelShimmeringView.stop()
        }

        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            options: [.curveEaseInOut, .transitionCrossDissolve],
            animations: animation
        )
    }

    private func startShimmering() {
        guard quoteLabel.content.isEmpty else { return }
        guard baseLabel.content.isEmpty else { return }
        fiatLabelShimmeringView?.start()
        baseFiatLabelShimmeringView?.start()
    }

    fileprivate func setup(with presentation: FiatBalanceViewAsset.Value.Presentation) {
        baseLabel.content = presentation.baseBalanceLabelContent
        switch presentation.quoteBalanceLabelContent {
        case .visible(let content):
            quoteLabel.content = content
            quoteLabel.isHidden = false
            stackView.addArrangedSubview(quoteLabel)
            stackView.addArrangedSubview(baseLabel)
        case .hidden:
            quoteLabel.content = .empty
            quoteLabel.isHidden = true
        }
    }
}

// MARK: - Rx

extension Reactive where Base: FiatBalanceView {
    var values: Binder<FiatBalanceViewAsset.Value.Presentation> {
        Binder(base) { view, presentation in
            view.setup(with: presentation)
        }
    }
}
