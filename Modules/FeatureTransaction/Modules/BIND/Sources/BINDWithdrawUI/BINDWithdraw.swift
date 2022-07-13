@_exported import BINDWithdrawDomain

import BlockchainComponentLibrary
import BlockchainNamespace
import Combine
import Errors
import SwiftUI
import ToolKit

public struct BINDWithdrawView: View {

    @EnvironmentObject private var service: BINDWithdrawService
    @ObservedObject private var search = DebounceTextFieldObserver(delay: .seconds(1))

    @MainActor private let success: (BINDBeneficiary) -> Void

    public init(success: @escaping (BINDBeneficiary) -> Void) {
        self.success = success
    }

    public var body: some View {
        VStack(alignment: .leading) {
            Group {
                searchView
                switch service.result {
                case .none:
                    emptyView
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
        Text(L10n.search.title)
            .typography(.paragraph2)
            .foregroundColor(.semantic.title)
        Input(
            text: $search.input,
            isFirstResponder: $isFirstResponder,
            placeholder: L10n.search.placeholder
        )
        .onChange(of: search.output) { term in
            service.search(term)
        }
    }

    @ViewBuilder private var emptyView: some View {
        Text(L10n.empty.info)
            .typography(.caption1)
            .foregroundColor(.semantic.body)
    }

    @ViewBuilder private func detailsView(_ bind: BINDBeneficiary) -> some View {
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
                    Text(L10n.disclaimer.title)
                        .foregroundColor(.semantic.title)
                    Text(L10n.disclaimer.description)
                        .foregroundColor(.semantic.body)
                }
                .typography(.caption1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Group {
                if case .success(let bind) = service.result {
                    PrimaryButton(
                        title: L10n.action.next,
                        isLoading: service.isLoading
                    ) {
                        Task(priority: .userInitiated) {
                            try await service.link(bind)
                            success(bind)
                        }
                    }
                } else {
                    PrimaryButton(
                        title: L10n.action.next,
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

extension BINDBeneficiary {

    fileprivate struct Row: Hashable {
        let title: String
        let value: String
    }

    fileprivate var ux: [Row] {
        [
            .init(title: L10n.information.bankName, value: agent.bankName),
            .init(title: L10n.information.alias, value: agent.label),
            .init(title: L10n.information.accountHolder, value: agent.name),
            .init(title: L10n.information.accountType, value: agent.accountType),
            .init(title: L10n.information.CBU, value: agent.address),
            .init(title: L10n.information.CUIL, value: agent.holderDocument)
        ]
    }
}

struct BINDWithdrawViewPreviews: PreviewProvider {

    static var previews: some View {

        BINDWithdrawView(success: { _ in })
            .environmentObject(
                BINDWithdrawService(
                    initialResult: nil,
                    repository: BINDWithdrawPreviewRepository()
                )
            )

        BINDWithdrawView(success: { _ in })
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

        BINDWithdrawView(success: { _ in })
            .environmentObject(
                BINDWithdrawService(
                    initialResult: .success(.preview),
                    repository: BINDWithdrawPreviewRepository()
                )
            )
    }
}

final class BINDWithdrawPreviewRepository: BINDWithdrawRepositoryProtocol {

    init() {}

    func currency(_ currency: String) -> BINDWithdrawPreviewRepository {
        self
    }

    func search(address: String) -> AnyPublisher<BINDBeneficiary, Nabu.Error> {
        Just(.preview)
            .setFailureType(to: NabuError.self)
            .delay(for: .seconds(1), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    func link(beneficiary beneficiaryId: String) -> AnyPublisher<Void, Nabu.Error> {
        Just(())
            .setFailureType(to: NabuError.self)
            .eraseToAnyPublisher()
    }
}
