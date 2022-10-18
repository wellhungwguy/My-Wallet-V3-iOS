// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformUIKit

/// A cell that displays a total balance and asset distribution
final class TotalBalanceTableViewCell: UITableViewCell {

    // MARK: - Injected

    /// Presenter should be injected
    var presenter: TotalBalanceViewPresenter! {
        didSet {
            if let presenter {
                titleLabel.content = presenter.titleContent
                balanceView.presenter = presenter.balancePresenter
                pieChartView.presenter = presenter.pieChartPresenter
                pieChartView.isHidden = false
            } else {
                balanceView.presenter = nil
                pieChartView.presenter = nil
                pieChartView.isHidden = true
            }
        }
    }

    // MARK: - IBOutlet Properties

    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var balanceView: AssetPriceView!
    @IBOutlet private var pieChartView: AssetPieChartView!
    @IBOutlet private var bottomSeparatorView: UIView!

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        bottomSeparatorView.backgroundColor = .lightBorder
        balanceView.shimmer(
            estimatedPriceLabelSize: CGSize(width: 140, height: 29),
            estimatedChangeLabelSize: CGSize(width: 120, height: 17)
        )
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        presenter = nil
    }
}
