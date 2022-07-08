@_exported import BINDWithdrawDomain

import BlockchainComponentLibrary
import BlockchainNamespace
import Combine
import Errors
import SwiftUI
import ToolKit

public struct BINDWithdrawView: View {

    @EnvironmentObject private var service: BINDWithdrawService
    @ObservedObject private var search = DebounceTextFieldObserver(delay: .milliseconds(500))

    @MainActor private let action: (BIND) -> Void

    public init(action: @escaping (BIND) -> Void) {
        self.action = action
    }

    public var body: some View {
        VStack(alignment: .leading) {
            Group {
                searchView
                switch service.result {
                case .none:
                    infoView
                case .success(let bind):
                    detailsView(bind)
                case .failure(let error):
                    Text(error.title)
                        .typography(.caption1)
                        .foregroundColor(.semantic.error)
                }
            }
            .padding([.leading, .trailing])
            Spacer()
            footerView
        }
        .background(Color.semantic.background)
    }

    @State private var isFirstResponder: Bool = false

    @ViewBuilder private var searchView: some View {
        Text("Alias/CBU/CVU")
            .typography(.paragraph2)
            .foregroundColor(.semantic.title)
        Input(
            text: $search.input,
            isFirstResponder: $isFirstResponder,
            placeholder: "Search"
        )
        .onChange(of: search.output) { term in
            service.search(term)
        }
    }

    @ViewBuilder private var infoView: some View {
        Text(
            """
            Please, enter your bank Alias/CBU/CVU to link a new bank account in your name.

            If you enter an alias:
            - It has to be between 6 and 20 characters (letters, numbers, dash and dot)
            - Don’t include the letter “ñ”, accents, gaps and other special characters.
            """
        )
        .typography(.caption1)
        .foregroundColor(.semantic.body)
    }

    @ViewBuilder private func detailsView(_ bind: BIND) -> some View {
        Color.clear
            .frame(height: 8.pt)
        List {
            ForEach(bind.ux, id: \.self) { row in
                PrimaryRow(
                    title: row.title,
                    trailing: { Text(row.value) }
                )
                .typography(.body1)
                .frame(height: 50.pt)
            }
        }
        .listStyle(.plain)
        .background(Color.semantic.background)
    }

    @ViewBuilder private var footerView: some View {
        VStack {
            HStack {
                Icon.bank
                    .aspectRatio(1, contentMode: .fit)
                    .frame(width: 24.pt)
                VStack(alignment: .leading) {
                    Text("Bank Transfers Only")
                        .foregroundColor(.semantic.title)
                    Text("Only send funds to a bank account in your name. If not, your withdrawal could be delayed or rejected.")
                        .foregroundColor(.semantic.body)
                }
                .typography(.caption1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Group {
                if case .success(let bind) = service.result {
                    PrimaryButton(title: "Next", isLoading: service.isLoading) {
                        Task {
                            try await service.link(bind)
                            action(bind)
                        }
                    }
                } else {
                    PrimaryButton(
                        title: "Next",
                        isLoading: service.isLoading
                    )
                    .disabled(true)
                }
            }
            .padding()
        }
        .padding([.leading, .top, .trailing])
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            Color.semantic.background
                .shadow(color: Color.semantic.dark, radius: 10, x: 0, y: 0)
                .mask(Rectangle().padding(.top, -20))
        )
    }
}

extension BIND {

    fileprivate struct Row: Hashable {
        let title: String
        let value: String
    }

    fileprivate var ux: [Row] {
        [
            .init(title: "Bank Name", value: bankName),
            .init(title: "Alias", value: label),
            .init(title: "Account Holder", value: accountHolder),
            .init(title: "Account Type", value: accountType),
            .init(title: "CBU", value: address),
            .init(title: "Account Number", value: accountNumber),
            .init(title: "CUIL", value: extraAttributes.documentId)
        ]
    }
}

struct BINDWithdrawViewPreviews: PreviewProvider {

    static var previews: some View {

        BINDWithdrawView(action: { _ in })
            .environmentObject(
                BINDWithdrawService(
                    initialResult: nil,
                    repository: BINDWithdrawPreviewRepository()
                )
            )

        BINDWithdrawView(action: { _ in })
            .environmentObject(
                BINDWithdrawService(
                    initialResult: .failure(
                        .init(
                            title: "Please, only send funds from a bank account in your name.",
                            message: "Please, only send funds from a bank account in your name."
                        )
                    ),
                    repository: BINDWithdrawPreviewRepository()
                )
            )

        BINDWithdrawView(action: { _ in })
            .environmentObject(
                BINDWithdrawService(
                    initialResult: .success(.preview),
                    repository: BINDWithdrawPreviewRepository()
                )
            )
    }
}

class BINDWithdrawPreviewRepository: BINDWithdrawRepositoryProtocol {

    init() {}

    func search(_ address: String) -> AnyPublisher<BIND, Nabu.Error> {
        Just(.preview)
            .setFailureType(to: NabuError.self)
            .delay(for: .seconds(1), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    func link(_ address: String) -> AnyPublisher<Void, Nabu.Error> {
        Just(())
            .setFailureType(to: NabuError.self)
            .eraseToAnyPublisher()
    }
}
