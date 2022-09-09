// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainUI
@_exported import FeatureOpenBankingDomain
import SwiftUI

public enum OpenBankingState: Equatable {
    case institutionList(InstitutionListState)
    case bank(BankState)
}

extension OpenBankingState {

    public static func linkBankAccount(_ bankAccount: OpenBanking.BankAccount? = nil) -> Self {
        if let bankAccount = bankAccount {
            return .institutionList(.init(result: .success(bankAccount)))
        } else {
            return .institutionList(.init())
        }
    }

    public static func deposit(
        amountMinor: String,
        product: String,
        from bankAccount: OpenBanking.BankAccount
    ) -> Self {
        .bank(
            BankState(
                data: .init(
                    account: bankAccount,
                    action: .deposit(
                        amountMinor: amountMinor,
                        product: product
                    )
                )
            )
        )
    }

    public static func confirm(
        order: OpenBanking.Order,
        from bankAccount: OpenBanking.BankAccount
    ) -> Self {
        .bank(
            BankState(
                data: .init(
                    account: bankAccount,
                    action: .confirm(
                        order: order
                    )
                )
            )
        )
    }
}

public enum OpenBankingAction: Equatable {
    case institutionList(InstitutionListAction)
    case bank(BankAction)
}

public let openBankingReducer = Reducer<OpenBankingState, OpenBankingAction, OpenBankingEnvironment>
    .combine(
        institutionListReducer
            .pullback(
                state: /OpenBankingState.institutionList,
                action: /OpenBankingAction.institutionList,
                environment: \.environment
            ),
        bankReducer
            .pullback(
                state: /OpenBankingState.bank,
                action: /OpenBankingAction.bank,
                environment: \.environment
            ),
        .init { _, action, environment in
            switch action {
            case .bank(.failure(let error)),
                 .institutionList(.bank(.failure(let error))):
                environment.eventPublisher.send(.failure(error))
                return .none
            case .institutionList(.bank(.finished)), .bank(.finished):
                environment.eventPublisher.send(.success(()))
                return .none
            case .bank(.cancel):
                return .fireAndForget(environment.cancel)
            case .institutionList, .bank:
                return .none
            }
        }
    )

public struct OpenBankingView: View {

    let store: Store<OpenBankingState, OpenBankingAction>

    public init(store: Store<OpenBankingState, OpenBankingAction>) {
        self.store = store
    }

    public var body: some View {
        SwitchStore(store) {
            CaseLet(
                state: /OpenBankingState.institutionList,
                action: OpenBankingAction.institutionList,
                then: InstitutionList.init(store:)
            )
            CaseLet(
                state: /OpenBankingState.bank,
                action: OpenBankingAction.bank,
                then: BankView.init(store:)
            )
        }
    }
}
