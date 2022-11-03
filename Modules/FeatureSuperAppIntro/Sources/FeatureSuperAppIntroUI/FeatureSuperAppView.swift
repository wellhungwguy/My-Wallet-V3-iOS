import BlockchainComponentLibrary
import BlockchainNamespace
import ComposableArchitecture
import Localization
import SwiftUI

public struct FeatureSuperAppIntroView: View {
    let store: StoreOf<FeatureSuperAppIntro>

    public init(store: StoreOf<FeatureSuperAppIntro>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            PrimaryNavigationView {
                contentView
                    .primaryNavigation(trailing: {
                        Button {
                            viewStore.send(.onDismiss)
                        } label: {
                            Icon.close
                        }
                    })
            }
        }
    }

    private var contentView: some View {
        WithViewStore(self.store) { viewStore in
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
                    title: LocalizationConstants.SuperAppIntro.CarouselPage1.title,
                    text: LocalizationConstants.SuperAppIntro.CarouselPage1.subtitle
                )
            case .newWayToNavigate:
                carouselView(
                    image: {
                        Image("image_superapp_intro_slide2", bundle: .featureSuperAppIntro)
                    },
                    title: LocalizationConstants.SuperAppIntro.CarouselPage2.title,
                    text: LocalizationConstants.SuperAppIntro.CarouselPage2.subtitle
                )
            case .newHomeForDefi:
                carouselView(
                    image: {
                        Image("image_superapp_intro_slide3", bundle: .featureSuperAppIntro)
                    },
                    title: LocalizationConstants.SuperAppIntro.CarouselPage3.title,
                    text: LocalizationConstants.SuperAppIntro.CarouselPage3.subtitle,
                    badge: LocalizationConstants.SuperAppIntro.CarouselPage3.badge,
                    badgeTint: .semantic.defi
                )
            case .tradingAccount:
                carouselView(
                    image: {
                        Image("image_superapp_intro_slide4", bundle: .featureSuperAppIntro)
                    },
                    title: LocalizationConstants.SuperAppIntro.CarouselPage4.title,
                    text: LocalizationConstants.SuperAppIntro.CarouselPage4.subtitle,
                    badge: LocalizationConstants.SuperAppIntro.CarouselPage4.badge,
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

                    if let badge {
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
        WithViewStore(store) { viewStore in
            TabView(
                selection: viewStore.binding(
                    get: { $0.currentStep },
                    send: { .didChangeStep($0) }
                )
            ) {
                Carousel.walletJustGotBetter.makeView()
                    .tag(FeatureSuperAppIntro.State.Step.walletJustGotBetter)
                Carousel.newWayToNavigate.makeView()
                    .tag(FeatureSuperAppIntro.State.Step.newWayToNavigate)
                Carousel.newHomeForDefi.makeView()
                    .tag(FeatureSuperAppIntro.State.Step.newHomeForDefi)
                Carousel.tradingAccount.makeView()
                    .tag(FeatureSuperAppIntro.State.Step.tradingAccount)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
        }
    }

    @ViewBuilder private func buttonsSection() -> some View {
        WithViewStore(store) { viewStore in
            if viewStore.currentStep == .tradingAccount {
                VStack(spacing: .zero) {
                    Spacer()
                    PrimaryButton(title: LocalizationConstants.SuperAppIntro.getStartedButton, action: {
                        viewStore.send(.onDismiss)
                    })
                }
                .padding(.horizontal, Spacing.padding3)
                .opacity(viewStore.gradientBackgroundOpacity)
            } else {
                EmptyView()
            }
        }
    }
}

struct FeatureSuperAppIntroView_Previews: PreviewProvider {
    static var previews: some View {
        FeatureSuperAppIntroView(store: Store(
            initialState: .init(),
            reducer: FeatureSuperAppIntro(onDismiss: {})
        )
                                 )
    }
}

extension AppMode {
    public var displayName: String {
        switch self {
        case .pkw:
            return LocalizationConstants.AppMode.privateKeyWallet
        case .trading:
            return LocalizationConstants.AppMode.tradingAccount
        case .universal:
            return ""
        }
    }
}
