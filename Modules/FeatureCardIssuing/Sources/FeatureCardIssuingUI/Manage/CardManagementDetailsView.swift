// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import ComposableArchitecture
import FeatureCardIssuingDomain
import Localization
import PassKit
import SceneKit
import SwiftUI
import ToolKit

struct CardManagementDetailsView: View {

    private typealias L10n = LocalizationConstants.CardIssuing.Manage.Details

    private let store: Store<CardManagementState, CardManagementAction>

    @State var isPresented = false

    init(store: Store<CardManagementState, CardManagementAction>) {
        self.store = store
    }

    var body: some View {
        WithViewStore(store.scope(state: \.error)) { viewStore in
            switch viewStore.state {
            case .some(let error):
                ErrorView(
                    error: error,
                    cancelAction: {
                        viewStore.send(.close)
                    }
                )
            default:
                content
            }
        }
    }

    @ViewBuilder var content: some View {
        WithViewStore(store) { viewStore in
            ScrollView {
                LazyVStack(spacing: 0) {
                    header
                    PrimaryRow(
                        title: L10n.Lock.title,
                        subtitle: L10n.Lock.subtitle,
                        trailing: {
                            PrimarySwitch(
                                accessibilityLabel: L10n.title,
                                isOn: viewStore.binding(\.$isLocked)
                            )
                        },
                        action: {}
                    )
                    PrimaryDivider()
                    PrimaryRow(
                        title: L10n.Personal.title,
                        subtitle: L10n.Personal.subtitle,
                        trailing: { chevronRight },
                        action: {
                            viewStore.send(.editAddress)
                        }
                    )
                    PrimaryDivider()
                    PrimaryRow(
                        title: L10n.Support.title,
                        subtitle: L10n.Support.subtitle,
                        trailing: { chevronRight },
                        action: {
                            viewStore.send(.showSupportFlow)
                        }
                    )
                    DestructiveMinimalButton(title: L10n.delete) {
                        viewStore.send(.binding(.set(\.$isDeleteCardPresented, true)))
                    }
                    .padding(Spacing.padding3)
                }
                .listStyle(PlainListStyle())
                .background(Color.semantic.background.ignoresSafeArea())
            }
            .bottomSheet(
                isPresented: viewStore.binding(\.$isDeleteCardPresented),
                content: {
                    CloseCardView(store: store)
                }
            )
            .bottomSheet(isPresented: $isPresented) {
                AddToWalletView(
                    coordinator: viewStore.state.tokenisationCoordinator,
                    card: viewStore.state.card,
                    cardholderName: viewStore.state.cardholderName,
                    callback: { _, _ in
                        isPresented = false
                    }
                )
            }
        }
    }

    @ViewBuilder var header: some View {
        WithViewStore(store) { viewStore in
            VStack(spacing: Spacing.padding2) {
                HStack {
                    Text(LocalizationConstants.CardIssuing.Navigation.title)
                        .typography(.title3)
                        .padding([.top], Spacing.padding1)
                    Spacer()
                    Icon.closeCirclev2
                        .frame(width: 24, height: 24)
                        .onTapGesture(perform: {
                            viewStore.send(.closeDetails)
                        })
                }
                HStack {
                    VStack(alignment: .leading, spacing: Spacing.padding1) {
                        HStack {
                            Text(L10n.virtualCard)
                                .typography(.paragraph2)
                                .foregroundColor(.semantic.title)
                            Spacer()
                            Text("***\(viewStore.state.card?.last4 ?? "")")
                                .typography(.paragraph1)
                                .foregroundColor(.semantic.muted)
                        }
                        Text(viewStore.state.card?.status.localizedString ?? "-")
                            .typography(.caption2)
                            .foregroundColor(viewStore.state.card?.status.color)
                    }
                    .padding(.leading, 16)
                    .padding(.vertical, 18)
                    .padding(.trailing, 16)
                }
                .frame(maxWidth: .infinity)
                .background(Color.semantic.light)
                .cornerRadius(Spacing.padding1)
                .overlay(
                    RoundedRectangle(cornerRadius: Spacing.padding1)
                        .stroke(Color.semantic.muted, lineWidth: 1)
                )
                if viewStore.state.isTokenisationEnabled {
                    AddToWalletButton {
                        isPresented = true
                    }
                }
            }
            .padding([.top, .trailing, .leading], Spacing.padding3)
        }
    }

    @ViewBuilder var chevronRight: some View {
        Icon.chevronRight
            .color(
                .semantic.muted
            )
            .frame(width: 18, height: 18)
            .flipsForRightToLeftLayoutDirection(true)
    }
}

extension Card.Status {

    var color: Color {
        switch self {
        case .initiated, .created, .unactivated:
            return .semantic.primaryMuted
        case .active:
            return .semantic.success
        case .locked:
            return .semantic.error
        case .terminated:
            return .semantic.body
        case .unsupported, .limited, .suspended:
            return .semantic.orangeBG
        }
    }
}

#if DEBUG
struct CardManagementDetails_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CardManagementDetailsView(
                store: Store(
                    initialState: .init(tokenisationCoordinator: PassTokenisationCoordinator(service: MockServices())),
                    reducer: cardManagementReducer,
                    environment: .preview
                )
            )
        }
    }
}
#endif

struct AddToWalletButton: UIViewRepresentable {

    let action: (() -> Void)?

    func makeUIView(context: Context) -> some UIView {
        let button = PKAddPassButton(addPassButtonStyle: .black)
        button.addTarget(context.coordinator, action: #selector(Coordinator.onTap), for: .touchUpInside)
        return button
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(action: action)
    }

    class Coordinator: NSObject {
        let action: (() -> Void)?

        init(action: (() -> Void)?) {
            self.action = action
        }

        @objc func onTap() {
            action?()
        }
    }
}

struct AddToWalletView: UIViewControllerRepresentable {

    let coordinator: PassTokenisationCoordinator
    let card: Card?
    let cardholderName: String
    let callback: ((PKPaymentPass?, Error?) -> Void)?

    func makeUIViewController(context: Context) -> PKAddPaymentPassViewController {

        guard let configuration = PKAddPaymentPassRequestConfiguration(encryptionScheme: .ECC_V2) else {
            return PKAddPaymentPassViewController()
        }
        configuration.primaryAccountSuffix = card?.last4
        configuration.cardholderName = cardholderName

        return PKAddPaymentPassViewController(requestConfiguration: configuration, delegate: context.coordinator) ?? PKAddPaymentPassViewController()
    }

    func updateUIViewController(_ uiViewController: PKAddPaymentPassViewController, context: Context) {}

    func makeCoordinator() -> PassTokenisationCoordinator {
        coordinator.parent = self
        return coordinator
    }
}

public final class PassTokenisationCoordinator: NSObject, PKAddPaymentPassViewControllerDelegate {

    var parent: AddToWalletView?

    private var service: CardServiceAPI
    private var cancellables: Set<AnyCancellable> = []

    init(service: CardServiceAPI) {
        self.service = service
    }

    public func addPaymentPassViewController(
        _ controller: PKAddPaymentPassViewController,
        generateRequestWithCertificateChain certificates: [Data],
        nonce: Data,
        nonceSignature: Data,
        completionHandler handler: @escaping (PKAddPaymentPassRequest) -> Void
    ) {
        guard let card = parent?.card else {
            parent?.callback?(nil, nil)
            return
        }
        service
            .tokenise(
                card: card,
                with: certificates,
                nonce: nonce,
                nonceSignature: nonceSignature
            )
            .receive(on: DispatchQueue.main)
            .handleEvents(
                receiveOutput: {
                    handler($0)
                },
                receiveCompletion: { [weak self] result in
                    guard case .failure(let error) = result else {
                        return
                    }
                    self?.parent?.callback?(nil, error)
                }
            )
            .subscribe()
            .store(in: &cancellables)
    }

    public func addPaymentPassViewController(
        _ controller: PKAddPaymentPassViewController,
        didFinishAdding pass: PKPaymentPass?,
        error: Error?
    ) {
        print("PK:", error.description)
        DispatchQueue.main.async { [weak self] in
            self?.parent?.callback?(pass, error)
        }
    }
}
