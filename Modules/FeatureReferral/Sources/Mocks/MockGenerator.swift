// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureReferralDomain
import Foundation

public enum MockGenerator {
    public static var referral: Referral {
        Referral(
            code: "DG831FZ",
            rewardTitle: "Get 30$",
            rewardSubtitle: "Increase your earnings on each successful invite",
            criteria: [
                Step(text: "Sign up using your code"),
                Step(text: "Verify their identity"),
                Step(text: "Trade (min $50)")
            ],
            promotion: nil,
            announcement: nil
        )
    }
}
