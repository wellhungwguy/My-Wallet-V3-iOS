// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MoneyKit
@testable import PlatformKit

typealias AgentResponse = PlatformKit.PaymentAccount.Response.Agent
typealias PaymentAccountResponse = PlatformKit.PaymentAccount.Response

extension PaymentAccountResponse {
    static func mock(with currency: FiatCurrency, agent: AgentResponse) -> PaymentAccountResponse {
        .init(
            id: "response id",
            address: "response bank account",
            agent: agent,
            currency: .fiat(currency),
            state: .active
        )
    }
}

extension CustodialBalanceResponse {
    static let fullMock = CustodialBalanceResponse(
        balances: [
            "BTC": .zero,
            "BCH": .zero,
            "ETH": Balance(
                pending: "0",
                pendingDeposit: "0",
                pendingWithdrawal: "0",
                available: "2000",
                withdrawable: "0",
                mainBalanceToDisplay: "2000"
            ),
            "PAX": .zero,
            "XLM": .zero,
            "ALGO": .zero
        ]
    )
}

extension AgentResponse {

    static let fullMock = AgentResponse(
        account: "agent account",
        address: "agent address",
        code: "agent code",
        country: "agent country",
        name: "agent name",
        recipient: "agent recipient",
        routingNumber: "agent routingNumber"
    )

    static let emptyMock = AgentResponse(
        account: nil,
        address: nil,
        code: nil,
        country: nil,
        name: nil,
        recipient: nil,
        routingNumber: nil
    )

    static let minimumGBPMock = AgentResponse(
        account: "agent account",
        address: nil,
        code: "agent code",
        country: nil,
        name: nil,
        recipient: "agent recipient",
        routingNumber: nil
    )

    static let minimumEURMock = AgentResponse(
        account: "agent account",
        address: nil,
        code: "agent code",
        country: nil,
        name: "agent name",
        recipient: nil,
        routingNumber: nil
    )

    static let idealEURMock = AgentResponse(
        account: "agent account",
        address: nil,
        code: "agent code",
        country: "agent country",
        name: "agent name",
        recipient: "agent recipient",
        routingNumber: nil
    )
}
