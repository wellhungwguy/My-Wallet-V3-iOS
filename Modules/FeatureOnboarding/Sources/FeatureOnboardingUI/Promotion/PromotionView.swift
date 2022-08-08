// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Algorithms
import BlockchainComponentLibrary
import BlockchainNamespace
import Errors
import SwiftUI

public struct PromotionAnnouncementView: View {

    @BlockchainApp var app
    @Environment(\.context) var context

    public let promotion: L & I_blockchain_ux_onboarding_type_promotion_announcement
    public let ux: UX.Dialog

    public init(_ promotion: L & I_blockchain_ux_onboarding_type_promotion, ux: UX.Dialog) {
        self.promotion = promotion.announcement
        self.ux = ux
    }

    public var body: some View {
        AnnouncementCard(
            title: ux.title,
            message: ux.message,
            background: {
                if let background = ux.style?.background {
                    background.aspectRatio(contentMode: .fill)
                }
            },
            leading: {
                if let icon = ux.icon {
                    AsyncMedia(url: icon.url)
                        .aspectRatio(contentMode: .fit)
                }
            }
        )
        .transition(.opacity)
        .onAppear {
            app.state.transaction { state in
                state.set(promotion, to: ux)
            }
            app.post(event: promotion, context: context)
        }
        .onTapGesture {
            app.post(
                event: promotion.action.then.launch.url,
                context: context + [
                    blockchain.ui.type.action.then.launch.url: ux.actions?.first?.url
                ]
            )
        }
    }
}

public struct PromotionView: View {

    @BlockchainApp var app
    @Environment(\.context) var context
    @Environment(\.presentationMode) var presentationMode

    public let promotion: L & I_blockchain_ux_onboarding_type_promotion_story
    public let ux: UX.Dialog

    public init(
        _ promotion: L & I_blockchain_ux_onboarding_type_promotion,
        ux: UX.Dialog
    ) {
        self.promotion = promotion.story
        self.ux = ux
    }

    public var body: some View {
        VStack {
            if let header = ux.header {
                Group {
                    header
                        .aspectRatio(16 / 9, contentMode: .fit)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.top, 36.pt)
            }
            Group {
                if let icon = ux.icon {
                    AsyncMedia(url: icon.url, placeholder: { Spacer() })
                        .aspectRatio(contentMode: .fit)
                        .transition(.opacity)
                } else {
                    Spacer()
                        .frame(minHeight: 20.pt, idealHeight: 120.pt, maxHeight: 240.pt)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Group {
                    Text(rich: ux.title)
                        .typography(.title2)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.bottom, 16.pt)
                    Text(rich: ux.message)
                        .typography(.body1)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .multilineTextAlignment(.center)
            .padding([.leading, .trailing], 24.pt)
            if let actions = ux.actions {
                Group {
                    if ux.icon.isNil {
                        Spacer()
                    } else {
                        Spacer()
                            .frame(minHeight: 16.pt, idealHeight: 50.pt, maxHeight: 160.pt)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    ForEach(actions.indexed(), id: \.element) { index, my in
                        if index == actions.startIndex {
                            PrimaryButton(
                                title: my.title,
                                action: { post(action: my) }
                            )
                        } else {
                            Button(my.title) {
                                post(action: my)
                            }
                            .typography(.body2)
                            .padding()
                        }
                    }
                }
                .padding([.leading, .trailing], 24.pt)
                .padding(.bottom, 32.pt)
            }
        }
        .backgroundTexture(ux.style?.background)
        .foregroundTexture(ux.style?.foreground)
        .onAppear {
            app.state.transaction { state in
                state.set(promotion, to: ux)
                state.set(promotion.action.then.close, to: Session.State.Function(dismiss))
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
                        action: { app.post(event: promotion.action.then.close, context: context) }
                    )
                )
            #endif
        }
        .ignoresSafeArea(.container, edges: .vertical)
        .id(promotion(\.id))
    }

    private func post(action ux: UX.Action) {
        Task(priority: .userInitiated) { @MainActor in
            switch ux.url {
            case let url?:
                dismiss()
                try await Task.sleep(nanoseconds: NSEC_PER_SEC / 2)
                app.post(
                    event: promotion.action.then.launch.url,
                    context: context + [blockchain.ui.type.action.then.launch.url: url]
                )
            case nil:
                app.post(
                    event: promotion.action.then.close,
                    context: context
                )
            }
        }
    }

    private func dismiss() {
        presentationMode.wrappedValue.dismiss()
    }
}

// swiftlint:disable line_length

struct PromotionViewPreview: PreviewProvider {

    static var previews: some View {
        PromotionView(
            blockchain.ux.onboarding.promotion.cowboys.welcome,
            ux: UX.Dialog(
                header: .init(
                    media: .init(
                        url: "https://firebasestorage.googleapis.com/v0/b/fir-staging-92d79.appspot.com/o/header-cowboys-promotion.svg?alt=media&token=7d6ee44d-95d6-49de-8cf4-6926b5ff73e5"
                    )
                ),
                title: "Sign up to win BIG!",
                message:
                    """
                    Enter your details to be entered for a chance to win rewards
                    """,
                actions: [
                    UX.Action(title: "Continue")
                ],
                style: UX.Style(
                    foreground: Color.white.hsbTexture,
                    background: Texture(
                        color: Color.black.hsbTexture.color,
                        media: Texture.Media(
                            url: "https://firebasestorage.googleapis.com/v0/b/fir-staging-92d79.appspot.com/o/prescott.png?alt=media&token=443cc5cb-0f04-4e46-9712-a052b2437fa1"
                        )
                    )
                )
            )
        )
        .app(App.preview)

        PromotionView(
            blockchain.ux.onboarding.promotion.cowboys.raffle,
            ux: UX.Dialog(
                header: .init(
                    media: .init(
                        url: "https://firebasestorage.googleapis.com/v0/b/fir-staging-92d79.appspot.com/o/header-cowboys-promotion.svg?alt=media&token=7d6ee44d-95d6-49de-8cf4-6926b5ff73e5"
                    )
                ),
                title: "You're all set!",
                message: "You've officially entered the raffle to win a signed Dak jersey. Winners will be announced MM/DD/YYYY",
                icon: .init(url: "https://firebasestorage.googleapis.com/v0/b/fir-staging-92d79.appspot.com/o/jersey.png?alt=media&token=b06e0215-09c9-4ef6-bc4b-73b050f807f7"),
                actions: [
                    UX.Action(title: "Continue")
                ],
                style: UX.Style(
                    foreground: Color.white.hsbTexture,
                    background: Texture(
                        color: Color.black.hsbTexture.color,
                        media: Texture.Media(
                            url: "https://firebasestorage.googleapis.com/v0/b/fir-staging-92d79.appspot.com/o/prescott.png?alt=media&token=443cc5cb-0f04-4e46-9712-a052b2437fa1"
                        )
                    )
                )
            )
        )
        .app(App.preview)

        PromotionView(
            blockchain.ux.onboarding.promotion.cowboys.verify.identity,
            ux: UX.Dialog(
                header: .init(
                    media: .init(
                        url: "https://firebasestorage.googleapis.com/v0/b/fir-staging-92d79.appspot.com/o/header-cowboys-promotion.svg?alt=media&token=7d6ee44d-95d6-49de-8cf4-6926b5ff73e5"
                    )
                ),
                title: "Win suite tickets for you and 7 friends",
                message:
                """
                **Verify your ID, refer 3+ friends**, and you'll be entered for a chance to win **8 tickets** to the **Blockchain.com suite** for the **December 11th** game against the Texans.\n\nWinners will be announced on [DATE]
                """,
                icon: .init(url: "https://firebasestorage.googleapis.com/v0/b/fir-staging-92d79.appspot.com/o/tickets.png?alt=media&token=b3fa42b6-55a7-4680-ba63-9d08657c0da3"),
                actions: [
                    UX.Action(title: "Continue")
                ],
                style: UX.Style(
                    foreground: Color.white.hsbTexture,
                    background: Texture(
                        color: Color.black.hsbTexture.color,
                        media: Texture.Media(
                            url: "https://firebasestorage.googleapis.com/v0/b/fir-staging-92d79.appspot.com/o/prescott.png?alt=media&token=443cc5cb-0f04-4e46-9712-a052b2437fa1"
                        )
                    )
                )
            )
        )
        .app(App.preview)
    }
}
