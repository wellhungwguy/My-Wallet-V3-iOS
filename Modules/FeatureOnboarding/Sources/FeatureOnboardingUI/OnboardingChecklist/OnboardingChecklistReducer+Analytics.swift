// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import ComposableArchitecture

private typealias AnalyticsEvent = AnalyticsEvents.New.OnboardingChecklist

extension Reducer where State == OnboardingChecklist.State,
    Action == OnboardingChecklist.Action,
    Environment == OnboardingChecklist.Environment
{

    func analytics() -> Reducer<State, Action, Environment> {
        combined(
            with: Reducer { state, action, environment in
                switch action {
                case .didSelectItem(let item, let selectionSource):
                    let completedItems = state.completedItems
                    return .fireAndForget {
                        if let peeksheetItem = AnalyticsEvent.PeeksheetItem(item: item) {
                            environment.analyticsRecorder.record(
                                event: AnalyticsEvent.peeksheetSelectionClicked(
                                    buttonClicked: selectionSource == .callToActionButton,
                                    currentStepCompleted: completedItems.count,
                                    item: peeksheetItem
                                )
                            )
                        }
                    }

                case .dismissFullScreenChecklist:
                    guard let firstPendingStep = state.firstPendingStep else {
                        return .none
                    }
                    return .fireAndForget {
                        environment.analyticsRecorder.record(
                            event: AnalyticsEvent.peeksheetDismissed(currentStepCompleted: firstPendingStep)
                        )
                    }

                case .presentFullScreenChecklist:
                    guard let firstPendingStep = state.firstPendingStep else {
                        return .none
                    }
                    return .merge(
                        .fireAndForget {
                            environment.analyticsRecorder.record(
                                event: AnalyticsEvent.peeksheetViewed(
                                    currentStepCompleted: firstPendingStep
                                )
                            )
                        },
                        .fireAndForget {
                            environment.analyticsRecorder.record(
                                event: AnalyticsEvent.peeksheetProcessClicked(
                                    currentStepCompleted: firstPendingStep
                                )
                            )
                        }
                    )

                default:
                    return .none
                }
            }
        )
    }
}

extension OnboardingChecklist.State {

    fileprivate var firstPendingStep: AnalyticsEvent.PendingStep? {
        guard let firstIncompleteItem else {
            return nil
        }
        guard let firstPendingStep = AnalyticsEvent.PendingStep(firstIncompleteItem.id) else {
            return nil
        }
        return firstPendingStep
    }
}
