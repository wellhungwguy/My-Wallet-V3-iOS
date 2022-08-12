// Copyright © Blockchain Luxembourg S.A. All rights reserved.

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
            titleLabel.text = LocalizationConstants.Referrals.SettingsScreen.buttonTitle
            subtitleLabel.text = viewModel.referral.rewardTitle
            if let url = viewModel.referral.icon?.url {
                loadImage(with: url, into: backgroundImageView)
            } else {
                backgroundImageView.image = UIImage(named: "referral-image", in: .module, with: nil)
            }
            accessibility = .id(viewModel.accessibilityID)
        }
    }

    // MARK: - Private IBOutlets

    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var subtitleLabel: UILabel!
    @IBOutlet private var backgroundImageView: UIImageView!
}
