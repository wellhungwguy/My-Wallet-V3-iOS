import BlockchainComponentLibrary
import ComposableArchitecture
import SwiftUI

public struct FeatureSuperAppIntroView: View {
    let store: Store<FeatureSuperAppIntroState, FeatureSuperAppIntroAction>
    @ObservedObject var viewStore: ViewStore<FeatureSuperAppIntroState, FeatureSuperAppIntroAction>
    @Environment(\.presentationMode) var presentationMode

    public init(store: Store<FeatureSuperAppIntroState, FeatureSuperAppIntroAction>) {
        self.store = store
        viewStore = ViewStore(store)
    }

    public var body: some View {
        PrimaryNavigationView {
            contentView
                .primaryNavigation(trailing: {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Icon.close
                    }
                })
        }
    }

    private var contentView: some View {
        VStack {
            ZStack {
                carouselContentSection()
                buttonsSection()
                    .padding(.bottom, Spacing.padding6)
            }
            .background(
                ZStack {
                    Color.white.ignoresSafeArea()
                    Image("gradient", bundle: .featureSuperAppIntro)
                        .resizable()
                        .opacity(viewStore.gradientBackgroundOpacity)
                        .ignoresSafeArea(.all)
                }
            )
        }
    }
}

extension FeatureSuperAppIntroView {
    public enum Carousel {
        case walletJustGotBetter
        case newWayToNavigate
        case newHomeForDefi
        case tradingAccount

        @ViewBuilder public func makeView() -> some View {
            switch self {
            case .walletJustGotBetter:
                carouselView(
                    image: {
                        Image("icon_blockchain_blue", bundle: .featureSuperAppIntro)
                    },
                    title: "Your Wallet just got better",
                    text: " We’ve made some major improvements to the Blockchain.com app."
                )
            case .newWayToNavigate:
                carouselView(
                    image: {
                        Image("image_superapp_intro_slide2", bundle: .featureSuperAppIntro)
                    },
                    title: "A new way to navigate",
                    text: " Easily move between Trading Account and DeFi Wallet."
                )
            case .newHomeForDefi:
                carouselView(
                    image: {
                        Image("image_superapp_intro_slide3", bundle: .featureSuperAppIntro)
                    },
                    title: "Your new home for DeFi",
                    text: "Access your Private Key Wallets and engage with web3 and decentralized finance.",
                    badge: "Held by you",
                    badgeTint: .semantic.defi
                )
            case .tradingAccount:
                carouselView(
                    image: {
                        Image("image_superapp_intro_slide4", bundle: .featureSuperAppIntro)
                    },
                    title: "Your trading account",
                    text: "Access your Trading and Rewards accounts and buy and sell crypto.",
                    badge: "Held by Blockchain.com",
                    badgeTint: .semantic.primary
                )
            }
        }

        @ViewBuilder private func carouselView(
            @ViewBuilder image: () -> Image,
            title: String,
            text: String,
            badge: String? = nil,
            badgeTint: Color? = nil
        ) -> some View {
            VStack {
                // Image
                VStack {
                    Spacer()
                    image()
                        .padding()
                }
                .frame(height: 300)

                // Labels
                VStack(
                    alignment: .center,
                    spacing: Spacing.padding3
                ) {
                    Text(title)
                        .lineLimit(1)
                        .typography(.title3)
                    Text(text)
                        .multilineTextAlignment(.center)
                        .frame(width: 80.vw)
                        .typography(.paragraph1)

                    if let badge = badge {
                        TagView(
                            text: badge,
                            variant: .default,
                            size: .small,
                            foregroundColor: badgeTint
                        )
                    }
                    Spacer()
                }
                .frame(height: 300)
            }
        }
    }

    @ViewBuilder private func carouselContentSection() -> some View {
        TabView(
            selection: viewStore.binding(
                get: { $0.currentStep },
                send: { .didChangeStep($0) }
            )
        ) {
            Carousel.walletJustGotBetter.makeView()
                .tag(FeatureSuperAppIntroState.Step.walletJustGotBetter)
            Carousel.newWayToNavigate.makeView()
                .tag(FeatureSuperAppIntroState.Step.newWayToNavigate)
            Carousel.newHomeForDefi.makeView()
                .tag(FeatureSuperAppIntroState.Step.newHomeForDefi)
            Carousel.tradingAccount.makeView()
                .tag(FeatureSuperAppIntroState.Step.tradingAccount)
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
    }

    @ViewBuilder private func buttonsSection() -> some View {
        if viewStore.currentStep == .tradingAccount {
            VStack(spacing: .zero) {
                Spacer()
                PrimaryButton(title: "Get Started", action: {
                    presentationMode.wrappedValue.dismiss()
                })
            }
            .padding(.horizontal, Spacing.padding3)
            .opacity(viewStore.gradientBackgroundOpacity)
        } else {
            EmptyView()
        }
    }
}

struct FeatureSuperAppIntroView_Previews: PreviewProvider {
    static var previews: some View {
        FeatureSuperAppIntroView(store: .init(
            initialState: .init(),
            reducer: FeatureSuperAppIntroModule.reducer,
            environment: ()
        )
        )
    }
}
