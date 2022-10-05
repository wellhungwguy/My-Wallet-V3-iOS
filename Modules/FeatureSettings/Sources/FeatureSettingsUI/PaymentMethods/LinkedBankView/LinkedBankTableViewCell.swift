// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformUIKit

final class LinkedBankTableViewCell: UITableViewCell {

    // MARK: - Properties

    var viewModel: LinkedBankViewModelAPI! {
        didSet {
            linkedBankView.viewModel = viewModel
        }
    }

    // MARK: - Private Properties

    private let linkedBankView = LinkedBankView()

    // MARK: - Setup

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(linkedBankView)
        linkedBankView.fillSuperview()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }
}
