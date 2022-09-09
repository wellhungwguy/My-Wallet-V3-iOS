// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import PlatformUIKit
import RxCocoa
import RxSwift

final class SimpleBalanceTableViewCell: UITableViewCell {

    /// Presenter should be injected
    var presenter: HistoricalBalanceCellPresenter? {
        willSet { disposeBag = DisposeBag() }
        didSet {
            guard let presenter = presenter else {
                assetBalanceView.presenter = nil
                badgeImageView.viewModel = nil
                assetTitleLabel.content = .empty
                return
            }

            assetBalanceView.presenter = presenter.balancePresenter
            presenter.thumbnail
                .drive(badgeImageView.rx.viewModel)
                .disposed(by: disposeBag)
            presenter.name
                .drive(assetTitleLabel.rx.content)
                .disposed(by: disposeBag)
            presenter.assetNetworkContent
                .compactMap { $0 }
                .drive(assetNetworkLabel.rx.content)
                .disposed(by: disposeBag)
            presenter.assetNetworkContent
                .map { $0 == nil }
                .drive(tagView.rx.isHidden)
                .disposed(by: disposeBag)
            presenter.displayCode
                .drive(assetCodeLabel.rx.content)
                .disposed(by: disposeBag)
        }
    }

    private var disposeBag = DisposeBag()

    // MARK: Private IBOutlets

    private var assetTitleLabel: UILabel = .init()
    private var assetCodeLabel: UILabel = .init()
    private var tagView = UIView()
    private var assetNetworkLabel: UILabel = .init()
    private var badgeImageView: BadgeImageView = .init()
    private var assetBalanceView: AssetBalanceView = .init()
    private var bottomSeparatorView: UIView = .init()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    // MARK: - Lifecycle

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    override func prepareForReuse() {
        super.prepareForReuse()
        presenter = nil
    }

    // MARK: - Private

    private func setup() {
        contentView.addSubview(badgeImageView)
        contentView.addSubview(assetBalanceView)
        contentView.addSubview(bottomSeparatorView)

        assetTitleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        assetTitleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        assetTitleLabel.numberOfLines = 1

        tagView.addSubview(assetNetworkLabel)
        tagView.isHidden = true
        tagView.layer.cornerRadius = 4
        tagView.layer.borderColor = UIColor.gray2.cgColor
        tagView.layer.borderWidth = 1

        assetNetworkLabel.layoutToSuperview(.centerX, .centerY)
        assetNetworkLabel.layoutToSuperview(.top, offset: 3)
        assetNetworkLabel.layoutToSuperview(.left, offset: Spacing.standard)
        assetNetworkLabel.layoutToSuperview(.right, offset: -Spacing.standard)
        assetNetworkLabel.layoutToSuperview(.bottom, offset: -3)

        let assetCodeAndBadgeContainer = UIStackView(
            arrangedSubviews: [assetCodeLabel, tagView]
        )
        assetCodeAndBadgeContainer.axis = .horizontal
        assetCodeAndBadgeContainer.alignment = .center
        assetCodeAndBadgeContainer.spacing = Spacing.standard

        let assetStackView = UIStackView(
            arrangedSubviews: [assetTitleLabel, assetCodeAndBadgeContainer]
        )
        assetStackView.spacing = Spacing.interItem
        assetStackView.axis = .vertical
        assetStackView.alignment = .top

        contentView.addSubview(assetStackView)

        assetStackView.layoutToSuperview(.centerY)
        assetStackView.layoutToSuperview(.top, relation: .greaterThanOrEqual, offset: Spacing.inner)
        assetStackView.layout(edge: .leading, to: .trailing, of: badgeImageView, offset: Spacing.inner)
        assetStackView.layoutToSuperview(.bottom, relation: .lessThanOrEqual, offset: Spacing.inner)

        assetStackView.layout(edge: .trailing, to: .leading, of: assetBalanceView, offset: -Spacing.inner)

        badgeImageView.layout(dimension: .height, to: 32)
        badgeImageView.layout(dimension: .width, to: 32)
        badgeImageView.layoutToSuperview(.centerY)
        badgeImageView.layoutToSuperview(.leading, offset: Spacing.inner)

        assetBalanceView.layout(to: .top, of: assetStackView)
        assetBalanceView.layoutToSuperview(.centerY)
        assetBalanceView.layoutToSuperview(.trailing, offset: -Spacing.inner)
        assetBalanceView.layoutToSuperview(.bottom, relation: .lessThanOrEqual, offset: Spacing.inner)

        bottomSeparatorView.layout(dimension: .height, to: 1)
        bottomSeparatorView.layoutToSuperview(.trailing, priority: .defaultHigh)
        bottomSeparatorView.layoutToSuperview(.bottom, priority: .defaultHigh)
        bottomSeparatorView.layoutToSuperview(.width, relation: .equal, ratio: 0.82)

        bottomSeparatorView.backgroundColor = .lightBorder
        assetBalanceView.shimmer(
            estimatedFiatLabelSize: CGSize(width: 90, height: 16),
            estimatedCryptoLabelSize: CGSize(width: 100, height: 14)
        )
    }
}
