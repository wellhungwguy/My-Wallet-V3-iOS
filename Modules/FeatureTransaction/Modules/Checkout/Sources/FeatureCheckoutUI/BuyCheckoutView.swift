import BlockchainUI
import SwiftUI

typealias L10n = LocalizationConstants.Checkout

public struct BuyCheckoutView<Object: LoadableObject>: View where Object.Output == BuyCheckout, Object.Failure == Never {

    @BlockchainApp var app
    @Environment(\.context) var context

    @ObservedObject var viewModel: Object

    public init(viewModel: Object) {
        _viewModel = .init(wrappedValue: viewModel)
    }

    public var body: some View {
        AsyncContentView(
            source: viewModel,
            loadingView: Loading(),
            content: Loaded.init
        )
        .onAppear {
            app.post(
                event: blockchain.ux.transaction.checkout[].ref(to: context),
                context: context
            )
        }
    }
}

extension BuyCheckoutView {

    public init<P>(publisher: P) where P: Publisher, P.Output == BuyCheckout, P.Failure == Never, Object == PublishedObject<P, DispatchQueue> {
        viewModel = PublishedObject(publisher: publisher)
    }

    public init(_ checkout: Object.Output) where Object == PublishedObject<Just<BuyCheckout>, DispatchQueue> {
        self.init(publisher: Just(checkout))
    }
}

extension BuyCheckoutView {

    public struct Loading: View {

        public var body: some View {
            ZStack {
                Loaded(checkout: .preview)
                    .redacted(reason: .placeholder)
                ProgressView()
            }
        }
    }

    public struct Loaded: View {

        enum BuyType {
            case simpleBuy
            case recurringBuy
        }

        @BlockchainApp var app
        @Environment(\.context) var context
        @Environment(\.openURL) var openURL
        @State var isAvailableToTradeInfoPresented = false
        @State var isTermsInfoPresented = false

        let checkout: BuyCheckout
        let buyType: BuyType = .simpleBuy

        @State var information = (price: false, fee: false)
        @State var readyToRefresh = false

        public init(checkout: BuyCheckout) {
            self.checkout = checkout
        }

        init(checkout: BuyCheckout, information: (Bool, Bool) = (false, false)) {
            self.checkout = checkout
            _information = .init(wrappedValue: information)
        }
    }
}

extension BuyCheckoutView.Loaded {

    public var body: some View {
        VStack(alignment: .center, spacing: .zero) {
            if let expiration = checkout.quoteExpiration {
                CountdownView(
                    deadline: expiration,
                    readyToRefresh: $readyToRefresh
                )
                .padding()
            }
            ScrollView {
                header()
                PrimaryDivider()
                Group {
                    price()
                    PrimaryDivider()
                    Group {
                        TableRow(
                            title: L10n.Label.paymentMethod,
                            trailing: {
                                VStack(alignment: .trailing, spacing: .zero) {
                                    TableRowTitle(checkout.paymentMethod.name)
                                    if let detail = checkout.paymentMethod.detail {
                                        TableRowByline(detail)
                                    }
                                }
                            }
                        )
                    }
                    PrimaryDivider()
                    TableRow(
                        title: L10n.Label.purchase,
                        trailing: {
                            VStack(alignment: .trailing, spacing: .zero) {
                                TableRowTitle(checkout.fiat.displayString)
                                TableRowByline(checkout.crypto.displayString)
                            }
                        }
                    )
                    PrimaryDivider()
                    fees()
                    TableRow(
                        title: L10n.Label.total,
                        trailing: {
                            VStack(alignment: .trailing, spacing: .zero) {
                                TableRowTitle(checkout.total.displayString)
                                TableRowByline(checkout.crypto.displayString)
                            }
                        }
                    )
                    availableDates()
                }
                PrimaryDivider()
                disclaimer()
            }
            .overlayWithShadow(.top, color: .semantic.background)
            footer()
        }
        .backgroundTexture(.semantic.background)
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .bottomSheet(
            isPresented: $isAvailableToTradeInfoPresented
        ) {
            availableToTradeInfoSheet
        }
        .sheet(
            isPresented: $isTermsInfoPresented
        ) {
            termsInfoSheet
        }
    }

    @ViewBuilder var availableToTradeInfoSheet: some View {
        VStack(alignment: .leading, spacing: 19) {
            HStack {
                Text(L10n.AvailableToTradeInfo.title)
                    .typography(.body2)
                    .foregroundTexture(.semantic.title)
                Spacer()
                IconButton(icon: .closeCirclev2) {
                    isAvailableToTradeInfoPresented = false
                }
                .frame(width: 24.pt, height: 24.pt)
            }

            VStack(alignment: .leading, spacing: Spacing.padding2) {
                Text(L10n.AvailableToTradeInfo.description)
                    .typography(.body1)
                    .foregroundTexture(.semantic.text)
                SmallMinimalButton(title: L10n.AvailableToTradeInfo.learnMoreButton) {
                    isAvailableToTradeInfoPresented = false
                    Task { @MainActor in
                        try await openURL(app.get(blockchain.ux.transaction["buy"].checkout.terms.of.withdraw))
                    }
                }
            }
        }
        .padding(Spacing.padding3)
    }

    @ViewBuilder var termsInfoSheet: some View {
        PrimaryNavigationView {
            GeometryReader { geometry in
                ScrollView {
                    VStack(alignment: .leading, spacing: Spacing.padding2) {
                        let description: String = {
                            switch buyType {
                            case .simpleBuy:
                                return L10n.TermsInfo.simpleBuyDescription
                            case .recurringBuy:
                                return L10n.TermsInfo.recurringBuyDescription
                            }
                        }()
                        Text(
                            String(
                                format: description,
                                checkout.paymentMethod.name,
                                checkout.fiat.displayString,
                                formattedUpperRoundedDays(
                                    minutes: checkout.depositTerms?.withdrawalLockMinutes,
                                    defaultDays: 7
                                )
                            )
                        )
                        .fixedSize(horizontal: false, vertical: true)
                        .typography(.body1)
                        .foregroundTexture(.semantic.text)
                    }
                    .padding(Spacing.padding3)
                    .primaryNavigation(
                        title: L10n.TermsInfo.title,
                        trailing: {
                            IconButton(icon: .closeCirclev2) {
                                isTermsInfoPresented = false
                            }
                            .frame(width: 24.pt, height: 24.pt)
                        }
                    )
                }
                .frame(width: geometry.size.width)
                .frame(height: geometry.size.height)
            }
        }
        PrimaryButton(title: L10n.TermsInfo.doneButton) {
            isTermsInfoPresented = false
        }
        .frame(alignment: .bottom)
        .padding([.horizontal, .bottom], Spacing.padding3)
    }

    @ViewBuilder func header() -> some View {
        VStack {
            Text(checkout.total.displayString)
                .typography(.title1)
                .foregroundTexture(.semantic.title)
            Text(checkout.crypto.displayString)
                .typography(.title3)
                .foregroundTexture(.semantic.text)
        }
        .padding()
    }

    @ViewBuilder func price() -> some View {
        TableRow(
            title: .init(L10n.Label.price(checkout.crypto.code)),
            inlineTitleButton: IconButton(icon: question(information.price), toggle: $information.price),
            trailing: {
                TableRowTitle(checkout.exchangeRate.displayString)
            }
        )
        if information.price {
            explain(L10n.Label.priceDisclaimer) {
                try await app.post(
                    value: app.get(blockchain.ux.transaction.checkout.exchange.rate.disclaimer.url) as URL,
                    of: blockchain.ux.transaction.checkout.exchange.rate.disclaimer.then.launch.url
                )
            }
        }
    }

    func question(_ isOn: Bool) -> Icon {
        Icon.questionCircle.micro().color(isOn ? .semantic.primary : .semantic.dark)
    }

    @ViewBuilder func fees() -> some View {
        if let fee = checkout.fee {
            TableRow(
                title: .init(L10n.Label.blockchainFee),
                inlineTitleButton: IconButton(icon: question(information.fee), toggle: $information.fee),
                trailing: {
                    if let promotion = fee.promotion {
                        HStack {
                            if promotion.isZero {
                                Text(rich: "~~\(fee.value.displayString)~~")
                                    .typography(.paragraph1)
                                    .foregroundColor(.semantic.text)
                            }
                            TagView(
                                text: promotion.isZero ? L10n.Label.free : promotion.displayString,
                                variant: .success,
                                size: .large
                            )
                        }
                    } else if fee.value.isZero {
                        TagView(text: L10n.Label.free, variant: .success, size: .large)
                    } else {
                        TableRowTitle(fee.value.displayString)
                    }
                }
            )
            if fee.value.isNotZero, information.fee {
                explain(L10n.Label.custodialFeeDisclaimer) {
                    try await app.post(
                        value: app.get(blockchain.ux.transaction.checkout.fee.disclaimer.url) as URL,
                        of: blockchain.ux.transaction.checkout.fee.disclaimer.then.launch.url
                    )
                }
            }
            PrimaryDivider()
        }
    }

    @ViewBuilder func availableDates() -> some View {
        if isUIPaymentsImprovementsEnabled {
            if let availableToTrade = checkout.depositTerms?.availableToTrade {
                PrimaryDivider()
                TableRow(
                    title: .init(L10n.Label.availableToTrade),
                    inlineTitleButton: IconButton(
                        icon: question(information.fee),
                        toggle: $isAvailableToTradeInfoPresented
                    ),
                    trailing: {
                        TableRowTitle(availableToTrade)
                    }
                )
            }

            if let availableToWithdraw = checkout.depositTerms?.availableToWithdraw {
                PrimaryDivider()
                TableRow(
                    title: .init(L10n.Label.availableToWithdraw),
                    trailing: {
                        TableRowTitle(availableToWithdraw)
                    }
                )
            }
        }
    }

    @ViewBuilder
    func explain(_ content: some StringProtocol, action: @escaping () async throws -> Void) -> some View {
        VStack(alignment: .leading) {
            Text(rich: content)
                .foregroundColor(.semantic.text)
            Button(L10n.Button.learnMore) {
                Task(priority: .userInitiated) { [app] in
                    do {
                        try await action()
                    } catch {
                        app.post(error: error)
                    }
                }
            }
        }
        .typography(.caption1)
        .transition(.scale.combined(with: .opacity))
        .padding()
        .background(Color.semantic.light)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding([.leading, .trailing], 8.pt)
    }

    @ViewBuilder func disclaimer() -> some View {
        VStack(alignment: .leading) {
            if isUIPaymentsImprovementsEnabled && checkout.paymentMethod.isACH {
                VStack(alignment: .leading, spacing: Spacing.padding2) {
                    let description: String = {
                        switch buyType {
                        case .simpleBuy:
                            return String(
                                format: L10n.AchTransferDisclaimer.simpleBuyDescription,
                                checkout.fiat.displayString,
                                checkout.crypto.code,
                                checkout.exchangeRate.displayString
                            )
                        case .recurringBuy:
                            return String(
                                format: L10n.AchTransferDisclaimer.recurringBuyDescription,
                                checkout.paymentMethod.name,
                                checkout.fiat.displayString
                            )
                        }
                    }()
                    Text(description)
                    .multilineTextAlignment(.leading)
                    SmallMinimalButton(title: L10n.AchTransferDisclaimer.readMoreButton) {
                        isTermsInfoPresented = true
                    }
                }
            } else {
                Text(L10n.Label.indicativeDisclaimer)
                    .multilineTextAlignment(.center)
                Text(rich: L10n.Label.termsOfService)
                .onTap(blockchain.ux.transaction.checkout.terms.of.service, \.then.launch.url) {
                    try await app.get(blockchain.ux.transaction.checkout.terms.of.service.url) as URL
                }
            }
        }
        .padding()
        .typography(.caption1)
        .foregroundColor(.semantic.text)
    }

    func confirmed() {
        app.post(
            event: blockchain.ux.transaction.checkout.confirmed[].ref(to: context),
            context: context
        )
    }

    @ViewBuilder
    func footer() -> some View {
        VStack(spacing: .zero) {
            if checkout.paymentMethod.isApplePay {
                ApplePayButton(action: confirmed)
            } else {
                PrimaryButton(
                    title: L10n.Button.buy(checkout.crypto.code),
                    isLoading: readyToRefresh,
                    action: confirmed
                )
                .disabled(readyToRefresh)
            }
        }
        .padding()
        .backgroundWithShadow(.top)
    }
}

extension BuyCheckoutView.Loaded {
    /// This function converts minutes into days and does day upper rounding
    /// Examples: 0m -> 0 days;  1m -> 1 day;  1440m -> 1 day;  1441m -> 2 days
    private func formattedUpperRoundedDays(minutes: Int?, defaultDays: Int) -> String {
        let roundedSeconds: TimeInterval = {
            let minutesInDay = 24 * 60
            let secondsInMinute = 60
            guard let minutes = minutes
            else { return TimeInterval(defaultDays * minutesInDay * secondsInMinute) }
            let remainder: Int = minutes % minutesInDay
            let add: Int = remainder == 0 ? 0 : minutesInDay
            return TimeInterval((minutes + add) * secondsInMinute)
        }()

        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day]
        formatter.unitsStyle = .full
        return formatter.string(from: roundedSeconds) ?? ""
    }
}

extension BuyCheckoutView.Loaded {
    private var isUIPaymentsImprovementsEnabled: Bool {
        app
            .remoteConfiguration
            .yes(if: blockchain.app.configuration.ui.payments.improvements.is.enabled)
    }
}

struct BuyCheckoutView_Previews: PreviewProvider {

    static var previews: some View {
        PrimaryNavigationView {
            BuyCheckoutView(.preview)
                .primaryNavigation(title: "Checkout")
        }
        .app(App.preview)
    }
}

#if canImport(PassKit)

import PassKit

private struct _ApplePayButton: UIViewRepresentable {
    func updateUIView(_ uiView: PKPaymentButton, context: Context) {}
    func makeUIView(context: Context) -> PKPaymentButton {
        PKPaymentButton(paymentButtonType: .plain, paymentButtonStyle: .black)
    }
}

struct ApplePayButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View { _ApplePayButton().frame(maxHeight: 44.pt) }
}

struct ApplePayButton: View {

    var button: Button<EmptyView>

    init(action: @escaping () -> Void) {
        button = Button(action: action, label: EmptyView.init)
    }

    var body: some View {
        button.buttonStyle(ApplePayButtonStyle())
    }
}
#endif
