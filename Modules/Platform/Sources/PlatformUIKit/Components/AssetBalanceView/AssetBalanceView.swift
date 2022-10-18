// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxCocoa
import RxSwift

public final class AssetBalanceView: ThreeLabelStackView {

    // MARK: - Injected

    public var presenter: AssetBalanceViewPresenter! {
        willSet {
            disposeBag = DisposeBag()
        }
        didSet {
            guard let presenter else {
                clear()
                return
            }

            presenter.alignment
                .drive(rx.alignment)
                .disposed(by: disposeBag)

            presenter.state
                .compactMap(\.value)
                .bindAndCatch(to: rx.values)
                .disposed(by: disposeBag)

            presenter.state
                .map(\.isLoading)
                .mapToVoid()
                .bind { [weak self] in
                    self?.startShimmering()
                }
                .disposed(by: disposeBag)

            presenter.state
                .filter { $0.isLoading == false }
                .mapToVoid()
                .bind { [weak self] in
                    self?.stopShimmering()
                }
                .disposed(by: disposeBag)
        }
    }

    // MARK: - Private Properties

    fileprivate var fiatBalanceLabel: UILabel {
        topLabel
    }

    fileprivate var cryptoBalanceLabel: UILabel {
        middleLabel
    }

    fileprivate var pendingCryptoBalanceLabel: UILabel {
        bottomLabel
    }

    fileprivate var fiatLabelShimmeringView: ShimmeringView!
    fileprivate var cryptoLabelShimmeringView: ShimmeringView!

    private var disposeBag = DisposeBag()

    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
        clipsToBounds = true
    }

    /// Should be called once when the parent view loads
    public func shimmer(estimatedFiatLabelSize: CGSize, estimatedCryptoLabelSize: CGSize) {
        fiatLabelShimmeringView?.removeFromSuperview()
        cryptoLabelShimmeringView?.removeFromSuperview()

        fiatLabelShimmeringView = ShimmeringView(
            in: self,
            anchorView: cryptoBalanceLabel,
            size: estimatedFiatLabelSize
        )
        cryptoLabelShimmeringView = ShimmeringView(
            in: self,
            anchorView: fiatBalanceLabel,
            size: estimatedCryptoLabelSize
        )
    }

    private func stopShimmering() {
        guard fiatLabelShimmeringView != nil else { return }
        guard cryptoLabelShimmeringView != nil else { return }
        guard fiatLabelShimmeringView.isShimmering, cryptoLabelShimmeringView.isShimmering else { return }

        cryptoBalanceLabel.alpha = 0
        fiatBalanceLabel.alpha = 0

        let animation = { [weak self] in
            self?.cryptoBalanceLabel.alpha = 1
            self?.fiatBalanceLabel.alpha = 1
            self?.fiatLabelShimmeringView.stop()
            self?.cryptoLabelShimmeringView.stop()
        }
        let completion: (Bool) -> Void = { [weak self] _ in
            self?.fiatLabelShimmeringView.removeFromSuperview()
            self?.cryptoLabelShimmeringView.removeFromSuperview()
            self?.fiatLabelShimmeringView = nil
            self?.cryptoLabelShimmeringView = nil
        }

        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            options: [.curveEaseInOut, .transitionCrossDissolve],
            animations: animation,
            completion: completion
        )
    }

    private func startShimmering() {
        guard cryptoBalanceLabel.content.isEmpty else { return }
        guard fiatBalanceLabel.content.isEmpty else { return }
        fiatLabelShimmeringView.start()
        cryptoLabelShimmeringView.start()
    }
}

// MARK: - Rx

extension Reactive where Base: AssetBalanceView {
    var values: Binder<AssetBalanceViewModel.Value.Presentation> {
        Binder(base) { view, values in
            view.fiatBalanceLabel.content = values.primaryBalance
            view.cryptoBalanceLabel.content = values.secondaryBalance
            view.pendingCryptoBalanceLabel.content = values.pendingBalance
            view.pendingCryptoBalanceLabel.isHidden = values.pendingBalanceVisibility.isHidden
        }
    }
}
