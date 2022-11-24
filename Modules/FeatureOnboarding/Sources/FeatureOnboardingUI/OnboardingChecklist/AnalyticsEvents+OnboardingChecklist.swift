// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Foundation

extension AnalyticsEvents.New {

    enum OnboardingChecklist: AnalyticsEvent {

        var type: AnalyticsEventType {
            .nabu
        }

        /// This is not the last step completed, but the step that has to be taken next
        public enum PendingStep: String, StringRawRepresentable {
            case identityVerification = "0"
            case linkPaymentMethods = "1"
            case buyCrypto = "2"

            init?(_ itemId: FeatureOnboardingUI.OnboardingChecklist.Item.Identifier) {
                switch itemId {
                case .buyCrypto:
                    self = .buyCrypto
                case .linkPaymentMethods:
                    self = .linkPaymentMethods
                case .verifyIdentity:
                    self = .identityVerification
                default:
                    return nil
                }
            }
        }

        case peeksheetViewed(currentStepCompleted: PendingStep)
        case peeksheetDismissed(currentStepCompleted: PendingStep)
        case peeksheetProcessClicked(currentStepCompleted: PendingStep)
        case peeksheetSelectionClicked(
            buttonClicked: Bool,
            currentStepCompleted: Int,
            item: PeeksheetItem
        )

        enum PeeksheetItem: String, StringRawRepresentable {

            case buyCrypto = "BUY_CRYPTO"
            case linkPayment = "LINK_PAYMENT"
            case verifyIdentity = "VERIFY"

            init?(item: FeatureOnboardingUI.OnboardingChecklist.Item.Identifier) {
                switch item {
                case .buyCrypto:
                    self = .buyCrypto
                case .linkPaymentMethods:
                    self = .linkPayment
                case .verifyIdentity:
                    self = .verifyIdentity
                default:
                    return nil
                }
            }
        }
    }
}
