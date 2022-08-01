import Algorithms
import BlockchainComponentLibrary
import BlockchainNamespace
import Errors
import SwiftUI

public struct PromotionView: View {

    @BlockchainApp var app
    @Environment(\.context) var context
    @Environment(\.presentationMode) var presentationMode

    public let promotion: L & I_blockchain_ux_onboarding_type_promotion
    public let ux: UX.Dialog

    public init(
        _ promotion: L & I_blockchain_ux_onboarding_type_promotion,
        ux: UX.Dialog
    ) {
        self.promotion = promotion
        self.ux = ux
    }

    public var body: some View {
        VStack {
            ZStack(alignment: .bottom) {
                AsyncMedia(url: ux.style?.background?.media?.url)
                    .aspectRatio(contentMode: .fit)
                AsyncMedia(url: ux.icon?.url)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50.vw)
            }
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
        .onAppear {
            app.state.transaction { state in
                state.set(promotion, to: ux)
                state.set(promotion.then.close, to: Session.State.Function {
                    presentationMode.wrappedValue.dismiss()
                })
            }
            app.post(event: promotion, context: context)
        }
        .apply { view in
            #if os(iOS)
            view.navigationBarBackButtonHidden(true)
                .navigationBarItems(
                    leading: EmptyView(),
                    trailing: IconButton(
                        icon: Icon.closeCirclev2,
                        action: { app.post(event: promotion.then.close) }
                    )
                )
            #endif
        }
        .ignoresSafeArea(.container, edges: .top)
        .id(promotion(\.id))
    }

    private func post(action ux: UX.Action) {
        switch ux.url {
        case let url?:
            app.post(
                event: promotion.then.launch.url,
                context: [blockchain.ui.type.action.then.launch.url: url]
            )
        case nil:
            app.post(event: promotion.then.close)
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
                icon: UX.Icon(url: "https://firebasestorage.googleapis.com/v0/b/fir-staging-92d79.appspot.com/o/tickets%203.png?alt=media&token=79d00dab-0639-4631-b0ca-16aeb85f9d1b"),
                actions: [
                    UX.Action(title: "Verify my ID", url: "https://blockchain.com/app/kyc"),
                    UX.Action(title: "Maybe later")
                ],
                style: UX.Style(
                    background: Texture(
                        media: Texture.Media(
                            url: "https://firebasestorage.googleapis.com/v0/b/fir-staging-92d79.appspot.com/o/header.svg?alt=media&token=bf49b2cd-36ee-488c-ada8-7959c2a2eca1"
                        )
                    )
                )
            )
        )
        .app(App.preview)
    }
}


