// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import PlatformUIKit
import RxSwift

final class ActivityItemTableViewCell: UITableViewCell {

    // MARK: - Properties

    /// The presenter of the activity item
    var presenter: ActivityItemPresenter! {
        willSet {
            disposeBag = DisposeBag()
        }
        didSet {
            guard let presenter else { return }
            assetBalanceView.presenter = presenter.assetBalanceViewPresenter
            badgeImageView.viewModel = presenter.badgeImageViewModel

            presenter.titleLabelContent
                .drive(titleLabel.rx.content)
                .disposed(by: disposeBag)

            presenter.descriptionLabelContent
                .drive(descriptionLabel.rx.content)
                .disposed(by: disposeBag)
        }
    }

    // MARK: - Private IBOutlets

    @IBOutlet private var badgeImageView: BadgeImageView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var descriptionLabel: UILabel!
    @IBOutlet private var assetBalanceView: AssetBalanceView!
    @IBOutlet private var bottomSeparatorView: UIView!

    // MARK: - Private Properties

    private var disposeBag = DisposeBag()

    // MARK: - Setup

    override func awakeFromNib() {
        super.awakeFromNib()
        bottomSeparatorView.backgroundColor = .lightBorder
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        presenter = nil
    }
}
