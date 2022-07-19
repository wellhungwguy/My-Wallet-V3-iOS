// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import UIKit

final class FiatCustodialBalanceTableViewCell: UITableViewCell {

    // MARK: - Properties

    var presenter: FiatCustodialBalanceViewPresenter! {
        didSet {
            custodialBalanceView.presenter = presenter
        }
    }

    private let custodialBalanceView: FiatCustodialBalanceView

    // MARK: - Lifecycle

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        custodialBalanceView = FiatCustodialBalanceView()
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(custodialBalanceView)
        custodialBalanceView.layout(edges: .leading, .trailing, .top, .bottom, to: contentView)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        presenter = nil
    }
}
