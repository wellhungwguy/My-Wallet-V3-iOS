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
            presenter.displayCode
                .drive(assetCodeLabel.rx.content)
                .disposed(by: disposeBag)
        }
    }

    private var disposeBag = DisposeBag()

    // MARK: Private IBOutlets

    @IBOutlet private var assetTitleLabel: UILabel!
    @IBOutlet private var assetCodeLabel: UILabel!
    @IBOutlet private var badgeImageView: BadgeImageView!
    @IBOutlet private var assetBalanceView: AssetBalanceView!
    @IBOutlet private var bottomSeparatorView: UIView!

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        bottomSeparatorView.backgroundColor = .lightBorder
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
