// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import PlatformUIKit
import RxCocoa
import RxSwift

final class HistoricalBalanceTableViewCell: UITableViewCell {

    /// Presenter should be injected
    var presenter: HistoricalBalanceCellPresenter? {
        willSet { disposeBag = DisposeBag() }
        didSet {
            guard let presenter else {
                assetSparklineView.presenter = nil
                assetPriceView.presenter = nil
                assetBalanceView.presenter = nil
                badgeImageView.viewModel = nil
                assetTitleLabel.content = .empty
                return
            }

            assetSparklineView.presenter = presenter.sparklinePresenter
            assetPriceView.presenter = presenter.pricePresenter
            assetBalanceView.presenter = presenter.balancePresenter
            presenter.thumbnail
                .drive(badgeImageView.rx.viewModel)
                .disposed(by: disposeBag)
            presenter.name
                .drive(assetTitleLabel.rx.content)
                .disposed(by: disposeBag)
        }
    }

    private var disposeBag = DisposeBag()

    // MARK: Private IBOutlets

    @IBOutlet private var assetTitleLabel: UILabel!
    @IBOutlet private var badgeImageView: BadgeImageView!
    @IBOutlet private var assetSparklineView: AssetSparklineView!
    @IBOutlet private var assetPriceView: AssetPriceView!
    @IBOutlet private var assetBalanceView: AssetBalanceView!
    @IBOutlet private var separatorView: UIView!
    @IBOutlet private var bottomSeparatorView: UIView!

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        separatorView.backgroundColor = .lightBorder
        bottomSeparatorView.backgroundColor = .lightBorder
        assetPriceView.shimmer(
            estimatedPriceLabelSize: CGSize(width: 90, height: 19),
            estimatedChangeLabelSize: CGSize(width: 80, height: 18)
        )
        assetBalanceView.shimmer(
            estimatedFiatLabelSize: CGSize(width: 90, height: 16),
            estimatedCryptoLabelSize: CGSize(width: 100, height: 14)
        )
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        presenter = nil
    }
}
