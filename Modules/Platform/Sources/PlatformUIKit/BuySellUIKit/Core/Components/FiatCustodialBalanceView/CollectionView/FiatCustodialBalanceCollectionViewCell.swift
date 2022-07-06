// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import UIKit

final class FiatCustodialBalanceCollectionViewCell: UICollectionViewCell {

    // MARK: - Properties

    var presenter: FiatCustodialBalanceViewPresenter! {
        didSet {
            custodialBalanceView.presenter = presenter

            guard let presenter = presenter else {
                return
            }
            switch presenter.presentationStyle {
            case .plain:
                custodialBalanceView.layer.borderColor = Color.clear.cgColor
                custodialBalanceViewWidthConstraint.constant = UIScreen.main.bounds.width - Spacing.outer
                custodialBalanceViewWidthConstraint.isActive = true
            case .border:
                custodialBalanceView.layer.borderColor = Color.lightBorder.cgColor
                custodialBalanceViewWidthConstraint.isActive = false
            }
        }
    }

    private var custodialBalanceViewWidthConstraint: NSLayoutConstraint!
    private let custodialBalanceView: FiatCustodialBalanceView

    // MARK: - Setup

    override init(frame: CGRect) {
        custodialBalanceView = FiatCustodialBalanceView()
        custodialBalanceView.clipsToBounds = true
        custodialBalanceView.layer.cornerRadius = 16
        custodialBalanceView.layer.borderWidth = 1.0
        super.init(frame: frame)
        contentView.addSubview(custodialBalanceView)
        custodialBalanceView.layoutToSuperview(.top, .bottom, .leading, .trailing)
        custodialBalanceViewWidthConstraint = custodialBalanceView.layout(
            dimension: .width,
            to: UIScreen.main.bounds.width - Spacing.outer,
            priority: .penultimateHigh
        )
    }

    override func preferredLayoutAttributesFitting(
        _ layoutAttributes: UICollectionViewLayoutAttributes
    ) -> UICollectionViewLayoutAttributes {
        setNeedsLayout()
        layoutIfNeeded()
        let size = contentView.systemLayoutSizeFitting(layoutAttributes.size)
        var newFrame = layoutAttributes.frame
        newFrame.size.width = CGFloat(ceilf(Float(size.width + 8)))
        newFrame.size.height = CGFloat(ceilf(Float(size.height)))
        layoutAttributes.frame = newFrame
        return layoutAttributes
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    override func prepareForReuse() {
        presenter = nil
        super.prepareForReuse()
    }
}
