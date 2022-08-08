// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import Combine
import ComposableArchitecture
import FeatureCoinDomain
import Foundation
import Localization
import MoneyKit
import SwiftUI

public struct AccountListView: View {
    private typealias Localization = LocalizationConstants.Coin.Accounts

    @BlockchainApp var app
    @Environment(\.context) var context

    let accounts: [Account.Snapshot]
    let currency: CryptoCurrency

    let interestRate: Double?
    let kycStatus: KYCStatus?

    var __accounts: [Account.Snapshot] {
        switch kycStatus {
        case .none, .unverified, .inReview:
            return accounts.filter(\.isPrivateKey)
        case .silver, .silverPlus, .gold:
            return accounts
        }
    }

    var isDefiMode: Bool {
        accounts.count == 1 && accounts.first?.accountType == .privateKey
    }

    public var body: some View {
        VStack(spacing: 0) {
            if accounts.isEmpty {
                loading()
            } else if isDefiMode, let account = accounts.first {
                singleAccountRowWithActions(account: account)
            } else {
                ForEach(__accounts) { account in
                    AccountRow(
                        account: account,
                        assetColor: currency.color,
                        interestRate: interestRate
                    )
                    .context(
                        [
                            blockchain.ux.asset.account.id: account.id,
                            blockchain.ux.asset.account: account
                        ]
                    )
                    PrimaryDivider()
                }
                switch kycStatus {
                case .none, .unverified, .inReview:
                    locked()
                case .silver, .silverPlus, .gold:
                    EmptyView()
                }
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                    .stroke(isDefiMode ? Color.semantic.medium : .clear, lineWidth: 1)
        )
        .padding(.horizontal, Spacing.padding1)
    }

    @ViewBuilder func singleAccountRowWithActions(account: Account.Snapshot) -> some View {
        AccountRow(
            account: account,
            assetColor: currency.color,
            interestRate: interestRate,
            actionEnabled: false
        )
        .context([blockchain.ux.asset.account.id: account.id])

        HStack(alignment: .center) {
            MinimalButton(title: "Copy address") {
                Icon
                    .copy
                    .frame(width: 14, height: 14)
            } action: {
#if os(macOS)
                NSPasteboard.general.string = account.receiveAddress
#else
                UIPasteboard.general.string = account.receiveAddress
#endif
            }
            .typography(.paragraph2)
            .padding(.vertical, Spacing.padding2)
            .padding(.leading, Spacing.padding2)
            .padding(.trailing, Spacing.padding1)
            .pillButtonSize(.small)

            MinimalButton(title: "Receive") {
                Icon
                    .qrCode
                    .frame(width: 14, height: 14)
            } action: {
                app.post(event: blockchain.ux.asset.account.receive[].ref(to: context))
            }
            .typography(.paragraph2)
            .padding(.vertical, Spacing.padding2)
            .padding(.trailing, Spacing.padding2)
            .pillButtonSize(.small)
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder func loading() -> some View {
        Group {
            ForEach(1...3, id: \.self) { _ in
                LockedAccountRow(
                    title: Localization.tradingAccountTitle,
                    subtitle: Localization.tradingAccountSubtitle,
                    icon: .trade
                )
                PrimaryDivider()
            }
        }
        .disabled(true)
        .redacted(reason: .placeholder)
    }

    @ViewBuilder func locked() -> some View {
        if currency.supports(product: .custodialWalletBalance) {
            LockedAccountRow(
                title: Localization.tradingAccountTitle,
                subtitle: Localization.tradingAccountSubtitle,
                icon: .trade
            )
            .context([blockchain.ux.asset.account.type: Account.AccountType.trading])
            PrimaryDivider()
        }
        if currency.supports(product: .interestBalance) {
            LockedAccountRow(
                title: Localization.rewardsAccountTitle,
                subtitle: Localization.rewardsAccountSubtitle.interpolating(interestRate.or(0)),
                icon: .interestCircle
            )
            .context([blockchain.ux.asset.account.type: Account.AccountType.interest])
            PrimaryDivider()
        }
    }
}

// swiftlint:disable type_name
struct AccountListView_PreviewProvider: PreviewProvider {
    static var previews: some View {
        AccountListView(
            accounts: [
                .preview.privateKey,
                .preview.trading,
                .preview.rewards
            ],
            currency: .bitcoin,
            interestRate: nil,
            kycStatus: .gold
        )
        .previewDisplayName("Gold")
        AccountListView(
            accounts: [
                .preview.privateKey,
                .preview.trading,
                .preview.rewards
            ],
            currency: .bitcoin,
            interestRate: nil,
            kycStatus: .silver
        )
        .previewDisplayName("Silver")
        AccountListView(
            accounts: [
                .preview.privateKey,
                .preview.trading,
                .preview.rewards
            ],
            currency: .bitcoin,
            interestRate: nil,
            kycStatus: .unverified
        )
        .previewDisplayName("Unverified")

        AccountListView(
            accounts: [
                .preview.privateKey
            ],
            currency: .bitcoin,
            interestRate: nil,
            kycStatus: .unverified
        )
        .previewDisplayName("Single Account Defi")

        AccountListView(
            accounts: [
                .preview.privateKey,
                .preview.privateKey
            ],
            currency: .bitcoin,
            interestRate: nil,
            kycStatus: .unverified
        )
        .previewDisplayName("Double Account Defi")
    }
}

extension Account.Snapshot {
    var isPrivateKey: Bool { accountType == .privateKey }
}
