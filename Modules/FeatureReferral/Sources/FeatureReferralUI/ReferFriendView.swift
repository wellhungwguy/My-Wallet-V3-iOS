// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import ComposableArchitecture
import FeatureReferralMocks
import Localization
import SwiftUI
import UIComponentsKit

typealias LocalizedStrings = LocalizationConstants.Referrals.ReferralScreen

public struct ReferFriendView: View {
    let store: Store<ReferFriendState, ReferFriendAction>
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewStore: ViewStore<ReferFriendState, ReferFriendAction>

    public init(store: Store<ReferFriendState, ReferFriendAction>) {
        self.store = store
        viewStore = ViewStore(store)
    }

    public var body: some View {
        PrimaryNavigationView {
            contentView
        }
    }

    private var contentView: some View {
        VStack {
            ScrollView {
                imageSection
                inviteFriendsSection
                referalCodeSection
                Spacer()
                stepsSection
            }
            shareButton
        }
        .ignoresSafeArea(.all, edges: .bottom)
        .navigationBarTitleDisplayMode(.inline)
        .whiteNavigationBarStyle()
        .trailingNavigationButton(.close) {
            presentationMode.wrappedValue.dismiss()
        }
        .onAppear(perform: {
            viewStore.send(.onAppear)
        })
        .sheet(
            isPresented: viewStore
                .binding(\.$isShareModalPresented),
            content: {
                let itemtoShare = ActivityItemSource(
                    title: LocalizedStrings.shareTitle,
                    text: LocalizedStrings.shareMessage(viewStore.referralInfo.code)
                )
                ActivityViewController(itemsToShare: [itemtoShare])
            }
        )
    }
}

extension ReferFriendView {
    private var imageSection: some View {
        Image(
            "image_refer_blockchain",
            bundle: .module
        )
        .resizable()
        .frame(width: 80, height: 80)
    }

    private var inviteFriendsSection: some View {
        VStack(alignment: .center, spacing: 12, content: {
            Text(viewStore
                .referralInfo
                .rewardTitle)
                .typography(.title2)
                .foregroundColor(Color.textTitle)
            Text(viewStore
                .referralInfo
                .rewardSubtitle)
                .typography(.paragraph1)
                .foregroundColor(Color.textTitle)
                .frame(width: 220)
                .lineLimit(3)
                .multilineTextAlignment(.center)
        })
        .padding(.horizontal, Spacing.padding4)
        .padding(.top, Spacing.padding3)
    }

    private var referalCodeSection: some View {
        VStack(spacing: 6, content: {
            Text(LocalizedStrings.referalCodeLabel)
                .typography(.paragraph1)
                .foregroundColor(Color.textMuted)

            VStack(alignment: .center, spacing: Spacing.padding2, content: {
                Text(viewStore.referralInfo.code)
                    .typography(.title2)
                    .fontWeight(.medium)
                    .kerning(15)
                    .padding(.top, Spacing.padding3)
                let label = viewStore.state.codeIsCopied
                    ? LocalizedStrings.copiedLabel
                    : LocalizedStrings.copyLabel
                Button(label) {
                    viewStore.send(.onCopyTapped)
                }
                .typography(.paragraph2)
                .padding(.bottom, Spacing.padding3)
                .foregroundColor(Color.WalletSemantic.primary)
            })
            .frame(maxWidth: .infinity)
            .background(Color("color_code_background", bundle: .module))
        })
        .padding(.horizontal, Spacing.padding3)
        .padding(.top, Spacing.padding5)
    }

    private var stepsSection: some View {
        VStack(spacing: Spacing.padding4) {
            Text(LocalizedStrings.stepsTitleLabel)
                .typography(.paragraph1)
                .foregroundColor(Color.textMuted)
            VStack(alignment: .leading, spacing: Spacing.padding2, content: {
                if let steps = viewStore.state.referralInfo.steps {
                    ForEach(steps.indices, id: \.self) { index in
                        HStack {
                            numberView(with: index + 1)
                            Text(steps[index].text)
                                .typography(.paragraph1)
                                .foregroundColor(Color.textTitle)
                        }
                    }
                }
            })
        }
        .padding(.top, Spacing.padding5)
    }

    private var shareButton: some View {
        PrimaryButton(title: LocalizedStrings.shareButton) {
            viewStore.send(.onShareTapped)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, Spacing.padding3)
        .padding(.bottom, Spacing.padding4)
    }

    @ViewBuilder func numberView(with number: Int) -> some View {
        Text("\(number)")
            .typography(.body2)
            .foregroundColor(Color.WalletSemantic.primary)
            .padding(12)
            .background(Color.WalletSemantic.blueBG)
            .clipShape(Circle())
    }
}

struct ActivityViewController: UIViewControllerRepresentable {

    var itemsToShare: [Any]
    var servicesToShareItem: [UIActivity]?

    func makeUIViewController(
        context: UIViewControllerRepresentableContext<ActivityViewController>
    ) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: itemsToShare,
            applicationActivities: servicesToShareItem
        )
        return controller
    }

    func updateUIViewController(
        _ uiViewController: UIActivityViewController,
        context: UIViewControllerRepresentableContext<ActivityViewController>
    ) {}
}

class ActivityItemSource: NSObject, UIActivityItemSource {
    var title: String
    var text: String

    init(title: String, text: String) {
        self.title = title
        self.text = text
        super.init()
    }

    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        text
    }

    func activityViewController(
        _ activityViewController: UIActivityViewController,
        itemForActivityType activityType: UIActivity.ActivityType?
    ) -> Any? {
        text
    }

    func activityViewController(
        _ activityViewController: UIActivityViewController,
        subjectForActivityType activityType: UIActivity.ActivityType?
    ) -> String {
        if activityType == .mail {
            return title
        }
        return ""
    }
}
