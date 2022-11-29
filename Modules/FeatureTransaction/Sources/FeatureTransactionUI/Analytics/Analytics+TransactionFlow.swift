import AnalyticsKit
import PlatformKit

extension AnalyticsEvents.New {

    public enum TransactionFlow: AnalyticsEvent {

        public var type: AnalyticsEventType {
            .nabu
        }

        public enum FlowStep: String, StringRawRepresentable {
            case buy = "BUY"
            case swap = "SWAP"

            // swiftlint:disable:next cyclomatic_complexity
            init?(_ action: AssetAction) {
                switch action {
                case .buy:
                    self = .buy
                case .swap:
                    self = .swap
                case _:
                    return nil
                }
            }
        }

        // Get more access prompt
        case getMoreAccessWhenYouVerifyClicked(flowStep: FlowStep)
        case getMoreAccessWhenYouVerifyDismissed(flowStep: FlowStep)
    }
}
