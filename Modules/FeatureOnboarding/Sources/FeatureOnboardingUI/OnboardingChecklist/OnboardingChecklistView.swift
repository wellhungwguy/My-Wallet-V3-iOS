// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import BlockchainComponentLibrary
import BlockchainNamespace
import ComposableArchitecture
import ComposableNavigation
import Localization
import SwiftUI
import ToolKit
import UIComponentsKit

public struct OnboardingChecklistView: View {

    private let store: Store<OnboardingChecklist.State, OnboardingChecklist.Action>
    @ObservedObject private var viewStore: ViewStore<OnboardingChecklist.State, OnboardingChecklist.Action>

    public init(store: Store<OnboardingChecklist.State, OnboardingChecklist.Action>) {
        self.store = store
        viewStore = ViewStore(store)
    }

    public var body: some View {
        ModalContainer(
            title: LocalizationConstants.Onboarding.Checklist.screenTitle,
            subtitle: LocalizationConstants.Onboarding.Checklist.screenSubtitle,
            onClose: { viewStore.send(.dismissFullScreenChecklist) },
            topAccessory: {
                VStack(spacing: Spacing.padding2) {
                    CountedProgressView(
                        completedItemsCount: viewStore.completedItems.count,
                        totalItemsCount: viewStore.items.count
                    )

                    Text(LocalizationConstants.Onboarding.Checklist.listTitle)
                        .typography(.micro)
                        .foregroundColor(.semantic.body)
                }
            },
            content: {
                VStack(spacing: Spacing.padding3) {
                    VStack(alignment: .leading, spacing: Spacing.baseline) {
                        ForEach(viewStore.items) { item in
                            let completed = viewStore.completedItems.contains(item)
                            let pending = viewStore.pendingItems.contains(item)
                            OnboardingChecklistRow(
                                item: item,
                                status: rowStatusForState(completed: completed, pending: pending)
                            )
                            .onTapGesture {
                                if !completed {
                                    viewStore.send(
                                        .didSelectItem(item.id, .item)
                                    )
                                }
                            }
                        }
                    }
                    // add extra padding for required spacing
                    .padding(.top, Spacing.padding1)

                    Spacer()

                    if let item = viewStore.firstIncompleteItem {
                        Button(item.title) {
                            viewStore.send(
                                .didSelectItem(item.id, .callToActionButton)
                            )
                        }
                        .buttonStyle(
                            OnboardingChecklistButtonStyle(item: item)
                        )
                    }
                }
                .padding(.bottom, Spacing.padding3)
                .padding(.horizontal, Spacing.padding3)
            }
        )
        .onAppear {
            viewStore.send(.startObservingUserState)
        }
    }

    private func rowStatusForState(completed: Bool, pending: Bool) -> OnboardingChecklistRow.Status {
        guard completed else {
            guard pending else {
                return .incomplete
            }
            return .pending
        }
        return .complete
    }
}

struct OnboardingChecklistButtonStyle: ButtonStyle {

    let item: OnboardingChecklist.Item

    func makeBody(configuration: Configuration) -> some View {
        VStack {
            configuration
                .label
                .typography(.body2)
        }
        .accentColor(.white)
        .foregroundColor(.white)
        .padding(.vertical, Spacing.padding1)
        .padding(.horizontal, Spacing.padding2)
        .frame(maxWidth: .infinity, minHeight: 48)
        .background(
            RoundedRectangle(cornerRadius: Spacing.buttonBorderRadius)
                .fill(configuration.isPressed ? item.backgroundColor : item.accentColor)
        )
        .contentShape(Rectangle())
    }
}

// MARK: SwiftUI Preview

#if DEBUG

struct OnboardingChecklistView_Previews: PreviewProvider {

    static var previews: some View {
        OnboardingChecklistView(
            store: .init(
                initialState: OnboardingChecklist.State(),
                reducer: OnboardingChecklist.reducer,
                environment: OnboardingChecklist.Environment(
                    app: App.preview,
                    userState: .just(
                        UserState(
                            kycStatus: .notVerified,
                            hasLinkedPaymentMethods: false,
                            hasEverPurchasedCrypto: false
                        )
                    ),
                    presentBuyFlow: { _ in },
                    presentKYCFlow: { _ in },
                    presentPaymentMethodLinkingFlow: { _ in },
                    analyticsRecorder: NoOpAnalyticsRecorder()
                )
            )
        )

        OnboardingChecklistView(
            store: .init(
                initialState: OnboardingChecklist.State(),
                reducer: OnboardingChecklist.reducer,
                environment: OnboardingChecklist.Environment(
                    app: App.preview,
                    userState: .just(
                        UserState(
                            kycStatus: .verificationPending,
                            hasLinkedPaymentMethods: false,
                            hasEverPurchasedCrypto: false
                        )
                    ),
                    presentBuyFlow: { _ in },
                    presentKYCFlow: { _ in },
                    presentPaymentMethodLinkingFlow: { _ in },
                    analyticsRecorder: NoOpAnalyticsRecorder()
                )
            )
        )

        OnboardingChecklistView(
            store: .init(
                initialState: OnboardingChecklist.State(),
                reducer: OnboardingChecklist.reducer,
                environment: OnboardingChecklist.Environment(
                    app: App.preview,
                    userState: .just(
                        UserState(
                            kycStatus: .verified,
                            hasLinkedPaymentMethods: true,
                            hasEverPurchasedCrypto: false
                        )
                    ),
                    presentBuyFlow: { _ in },
                    presentKYCFlow: { _ in },
                    presentPaymentMethodLinkingFlow: { _ in },
                    analyticsRecorder: NoOpAnalyticsRecorder()
                )
            )
        )

        OnboardingChecklistView(
            store: .init(
                initialState: OnboardingChecklist.State(),
                reducer: OnboardingChecklist.reducer,
                environment: OnboardingChecklist.Environment(
                    app: App.preview,
                    userState: .just(
                        UserState(
                            kycStatus: .verified,
                            hasLinkedPaymentMethods: true,
                            hasEverPurchasedCrypto: true
                        )
                    ),
                    presentBuyFlow: { _ in },
                    presentKYCFlow: { _ in },
                    presentPaymentMethodLinkingFlow: { _ in },
                    analyticsRecorder: NoOpAnalyticsRecorder()
                )
            )
        )
    }
}

#endif
