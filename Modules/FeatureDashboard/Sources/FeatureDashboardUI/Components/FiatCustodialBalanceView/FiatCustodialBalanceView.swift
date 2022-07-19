// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformUIKit
import RxCocoa
import RxSwift

final class FiatCustodialBalanceView: UIView {

    // MARK: - Injected

    var presenter: FiatCustodialBalanceViewPresenter! {
        willSet {
            disposeBag = DisposeBag()
        }
        didSet {
            guard let presenter = presenter else {
                return
            }

            presenter
                .badgeImageViewModel
                .drive(rx.badgeViewModel)
                .disposed(by: disposeBag)

            presenter
                .currencyName
                .drive(fiatCurrencyNameLabel.rx.content)
                .disposed(by: disposeBag)

            presenter
                .currencyCode
                .drive(fiatCurrencyCodeLabel.rx.content)
                .disposed(by: disposeBag)

            button.rx.tap
                .bindAndCatch(to: presenter.tapRelay)
                .disposed(by: disposeBag)

            button.isEnabled = presenter.respondsToTaps

            fiatBalanceView.presenter = presenter.fiatBalanceViewPresenter
        }
    }

    // MARK: - Private IBOutlets

    fileprivate let badgeImageView = BadgeImageView()
    private let stackView = UIStackView()
    private let fiatCurrencyNameLabel = UILabel()
    private let fiatCurrencyCodeLabel = UILabel()
    private let fiatBalanceView = FiatBalanceView()
    private let button = UIButton()

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
        stackView.axis = .vertical

        addSubview(badgeImageView)
        addSubview(stackView)
        addSubview(fiatBalanceView)
        addSubview(button)

        button.fillSuperview()
        button.addTargetForTouchDown(self, selector: #selector(touchDown))
        button.addTargetForTouchUp(self, selector: #selector(touchUp))

        badgeImageView.layout(size: .edge(Sizing.badge))
        badgeImageView.layoutToSuperview(.centerY)
        badgeImageView.layoutToSuperview(.leading, offset: Spacing.inner)

        fiatCurrencyCodeLabel.verticalContentHuggingPriority = .penultimateHigh
        fiatCurrencyNameLabel.verticalContentHuggingPriority = .defaultHigh
        fiatCurrencyNameLabel.horizontalContentCompressionResistancePriority = .defaultHigh

        stackView.layout(edge: .leading, to: .trailing, of: badgeImageView, offset: Spacing.inner)
        stackView.layoutToSuperview(axis: .vertical, offset: Spacing.inner)
        stackView.addArrangedSubview(fiatCurrencyNameLabel)
        stackView.addArrangedSubview(fiatCurrencyCodeLabel)

        fiatBalanceView.layout(edge: .leading, to: .trailing, of: stackView, offset: Spacing.inner)
        fiatBalanceView.layoutToSuperview(axis: .vertical, offset: Spacing.inner)
        fiatBalanceView.layoutToSuperview(.trailing, offset: -Spacing.inner)
        fiatBalanceView.shimmer(
            estimatedFiatLabelSize: CGSize(width: 90, height: 16),
            estimatedCryptoLabelSize: CGSize(width: 90, height: 16)
        )
    }

    @objc
    private func touchDown() {
        backgroundColor = .hightlightedBackground
    }

    @objc
    private func touchUp() {
        backgroundColor = .white
    }
}

// MARK: - Rx

extension Reactive where Base: FiatCustodialBalanceView {
    var badgeViewModel: Binder<BadgeImageViewModel> {
        Binder(base) { view, viewModel in
            view.badgeImageView.viewModel = viewModel
        }
    }
}
