import BlockchainComponentLibrary
import ComposableArchitecture
import FeatureSettingsUI
import Localization
import SwiftUI

public struct DefiWalletIntroView: View {
    let store: Store<DefiWalletIntroState, DefiWalletIntroAction>
    @ObservedObject var viewStore: ViewStore<DefiWalletIntroState, DefiWalletIntroAction>
    @Environment(\.presentationMode) private var presentationMode

    public init(store: Store<DefiWalletIntroState, DefiWalletIntroAction>) {
        self.store = store
        viewStore = ViewStore(store)
    }

    public var body: some View {
        VStack {
            ScrollView {
                Image("icon-defiWallet-intro")
                    .frame(width: 80, height: 80)
                    .padding(.top, 140)

                VStack(spacing: 8) {
                    Text(LocalizationConstants.DefiWalletIntro.title)
                        .typography(.title2)
                    Text(LocalizationConstants.DefiWalletIntro.subtitle)
                        .typography(.paragraph1)
                }

                VStack(spacing: 8) {
                    introRow(
                        number: 1,
                        title: LocalizationConstants.DefiWalletIntro.step1Title,
                        subtitle: LocalizationConstants.DefiWalletIntro.step1Subtitle
                    )
                    introRow(
                        number: 2,
                        title: LocalizationConstants.DefiWalletIntro.step2Title,
                        subtitle: LocalizationConstants.DefiWalletIntro.step2Subtitle
                    )
                    introRow(
                        number: 3,
                        title: LocalizationConstants.DefiWalletIntro.step3Title,
                        subtitle: LocalizationConstants.DefiWalletIntro.step3Subtitle
                    )
                }
                .padding(.top, Spacing.padding4)
                .padding(.horizontal, Spacing.padding3)
            }

            Spacer()

            PrimaryButton(title: LocalizationConstants.DefiWalletIntro.enableButton) {
                viewStore.send(.onEnableDefiTap)
            }
            .padding(.horizontal, Spacing.padding3)
            .padding(.bottom, Spacing.padding2)
        }
        .trailingNavigationButton(.close) {
            presentationMode.wrappedValue.dismiss()
        }
        .ignoresSafeArea(.all, edges: .top)
    }

    @ViewBuilder private func introRow(
        number: Int,
        title: String,
        subtitle: String
    ) -> some View {
        PrimaryRow(
            title: title,
            subtitle: subtitle,
            leading: {
                numberView(with: number)
            },
            trailing: {
                EmptyView()
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.WalletSemantic.light, lineWidth: 1)
        )
    }

    @ViewBuilder private func numberView(with number: Int) -> some View {
        Text("\(number)")
            .typography(.body2)
            .foregroundColor(Color.WalletSemantic.primary)
            .padding(12)
            .background(Color.WalletSemantic.blueBG)
            .clipShape(Circle())
    }
}
