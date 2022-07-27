import Algorithms
import BlockchainComponentLibrary
import BlockchainNamespace
import Errors
import SwiftUI

public struct PromotionView: View {

    @BlockchainApp var app
    @Environment(\.presentationMode) var presentationMode

    public let promotion: I_blockchain_ux_onboarding_type_promotion
    public let ux: UX.Dialog

    public init(
        _ promotion: I_blockchain_ux_onboarding_type_promotion,
        ux: UX.Dialog
    ) {
        self.promotion = promotion
        self.ux = ux
    }

    public var body: some View {
        VStack {
            if let icon = ux.icon {
                AsyncMedia(url: icon.url)
                    .aspectRatio(contentMode: .fit)
            }
            Spacer()
            Group {
                Text(rich: ux.title)
                    .typography(.title2)
                    .padding(.bottom, 16.pt)
                Text(rich: ux.message)
                    .typography(.body1)
            }
            .multilineTextAlignment(.center)
            .foregroundColor(.semantic.title)
            .padding([.leading, .trailing], 24.pt)
            Spacer()
            if let actions = ux.actions {
                ForEach(actions.indexed(), id: \.element) { index, my in
                    if index == actions.startIndex {
                        PrimaryButton(
                            title: my.title,
                            action: { post(action: my) }
                        )
                    } else {
                        PrimaryWhiteButton(
                            title: my.title,
                            action: { post(action: my) }
                        )
                    }
                }
                .padding([.leading, .trailing], 24.pt)
            }
        }
        .ignoresSafeArea(.container, edges: .top)
        .id(promotion(\.id))
    }

    private func post(action ux: UX.Action) {
        switch ux.url {
        case let url?:
            app.post(
                event: promotion.then.launch.url,
                context: [
                    blockchain.ui.type.action.then.launch.url: url
                ]
            )
        case nil:
            app.post(
                event: promotion.then.close,
                context: [
                    blockchain.ui.type.action.then.close: Tag.Context.Computed { [presentationMode] in
                        presentationMode.wrappedValue.dismiss()
                    }
                ]
            )
        }
    }
}

// swiftlint:disable line_length

struct PromotionViewPreview: PreviewProvider {

    static var previews: some View {
        PromotionView(
            blockchain.ux.onboarding.promotion.cowboys.buy.crypto,
            ux: UX.Dialog(
                title: "Almost there!",
                message:
                """
                **Verify your ID** and start referring your friends!

                The person with the **most referrals** by MM/DD/YYYY will will the Grand Prize!
                """,
                icon: UX.Icon(url: "https://images.unsplash.com/photo-1472289065668-ce650ac443d2?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1738&q=80"),
                actions: [
                    UX.Action(title: "Verify my ID", url: "https://blockchain.page.link/app/kyc"),
                    UX.Action(title: "Maybe later")
                ]
            )
        )
        .app(App.preview)
    }
}
