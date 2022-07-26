import BlockchainComponentLibrary
import BlockchainNamespace
import SwiftUI
import Errors
import Algorithms

struct PromotionView: View {

    @BlockchainApp var app
    @Environment(\.presentationMode) var presentationMode

    let action: I_blockchain_ux_type_action
    let ux: UX.Error

    var body: some View {
        VStack {
            if let icon = ux.icon {
                AsyncMedia(url: icon.url)
                    .aspectRatio(contentMode: .fit)
            }
            Spacer()
            Group {
                Text(ux.title)
                    .typography(.title2)
                    .padding(.bottom, 16.pt)
                Text(ux.message)
                    .typography(.body1)
            }
            .multilineTextAlignment(.center)
            .foregroundColor(.semantic.title)
            .padding([.leading, .trailing])
            Spacer()
            ForEach(ux.actions.indexed(), id: \.element) { index, my in
                if index == ux.actions.startIndex {
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
            .padding([.leading, .trailing])
        }
        .ignoresSafeArea(.container, edges: .top)
    }

    private func post(action ux: UX.Action) {
        switch ux.url {
        case let url?:
            app.post(value: url, of: action.then.launch.url)
        case nil:
            presentationMode.wrappedValue.dismiss()
        }
    }
}

struct PromotionViewPreview: PreviewProvider {

    static var previews: some View {
        PromotionView(
            action: blockchain.ux.onboarding.promotion.cowboys.buy.crypto,
            ux: UX.Error(
                title: "Almost there!",
                message:
                """
                Verify your ID and start referring your friends!

                The person with the most referrals by MM/DD/YYYY will will the Grand Prize!
                """,
                icon: UX.Icon(url: "https://www.blockchain.com/static/img/icons/icon-card.svg"),
                actions: [
                    UX.Action(title: "Verify my ID", url: "https://blockchain.page.link/app/kyc"),
                    UX.Action(title: "Maybe later")
                ]
            )
        )
        .app(App.preview)
    }
}
