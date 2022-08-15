// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Errors
import FeatureReferralDomain
import Localization
import NukeExtensions
import PlatformUIKit
import UIKit

struct ReferralTableViewCellViewModel {
    let referral: Referral
    let accessibilityID = Accessibility.Identifier.Settings.ReferralCell.view

    init(
        referral: Referral
    ) {
        self.referral = referral
    }
}

final class ReferralTableViewCell: UITableViewCell {
    typealias ViewModel = ReferralTableViewCellViewModel

    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 16
        layer.masksToBounds = true
    }

    var viewModel: ViewModel! {
        didSet {
            if let announcement = viewModel.referral.announcement {
                configure(announcement)
            } else {
                titleLabel.text = LocalizationConstants.Referrals.SettingsScreen.buttonTitle
                subtitleLabel.text = viewModel.referral.rewardTitle
                backgroundImageView.image = UIImage(named: "referral-image", in: .module, with: nil)
            }
            accessibility = .id(viewModel.accessibilityID)
        }
    }

    // MARK: - Private IBOutlets

    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var subtitleLabel: UILabel!
    @IBOutlet private var backgroundImageView: UIImageView!

    private func configure(_ announcement: UX.Dialog) {
        titleLabel.text = announcement.title
        subtitleLabel.text = announcement.message
        if let media = announcement.style?.background?.media {
            loadImage(with: media.url, into: backgroundImageView)
        } else if let color = announcement.style?.background?.color {
            backgroundImageView.image = nil
            backgroundColor = UIColor(color.swiftUI)
        } else {
            backgroundImageView.image = nil
        }
        if let foregroundColor = announcement.style?.foreground?.color {
            titleLabel.textColor = UIColor(foregroundColor.swiftUI)
            subtitleLabel.textColor = UIColor(foregroundColor.swiftUI)
        }
    }
}
