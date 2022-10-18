// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxSwift

final class AccountGroupBalanceTableViewCell: UITableViewCell {

    var presenter: AccountGroupBalanceCellPresenter! {
        didSet {
            disposeBag = DisposeBag()
            guard let presenter else { return }
            accessibility = presenter.accessibility
            walletBalanceView.presenter = presenter.walletBalanceViewPresenter
            badgeImageView.viewModel = presenter.badgeImageViewModel

            presenter.description
                .drive(descriptionLabel.rx.content)
                .disposed(by: disposeBag)

            presenter.title
                .drive(titleLabel.rx.content)
                .disposed(by: disposeBag)
        }
    }

    // MARK: - Private Properties

    private var disposeBag = DisposeBag()

    // MARK: - Private IBOutlets

    @IBOutlet private var separatorView: UIView!
    @IBOutlet private var badgeImageView: BadgeImageView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var descriptionLabel: UILabel!
    @IBOutlet private var walletBalanceView: WalletBalanceView!

    override func awakeFromNib() {
        super.awakeFromNib()
        separatorView.backgroundColor = .lightBorder
    }
}
