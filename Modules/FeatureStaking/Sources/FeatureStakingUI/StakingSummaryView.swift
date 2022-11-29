// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Blockchain
import BlockchainUI
import FeatureStakingDomain
import SwiftUI

@MainActor
public struct StakingSummaryView: View {

    let id = blockchain.ux.earn.staking.summary

    @BlockchainApp var app
    @Environment(\.context) var context

    @ObservedObject var object = Object()

    let exchangeRate: MoneyValuePair

    public init(exchangeRate: MoneyValuePair) {
        self.exchangeRate = exchangeRate
    }

    public var body: some View {
        Group {
            if let model = object.model {
                Loaded(model: model, exchangeRate: exchangeRate)
            } else {
                BlockchainProgressView()
            }
        }
        .onAppear { object.start(on: app, in: context) }
        .onAppear {
            app.post(event: id, context: context)
        }
    }
}

extension StakingSummaryView {

    struct Loaded: View {

        let id = blockchain.ux.earn.staking.summary

        @BlockchainApp var app
        @Environment(\.context) var context

        static let percentageFormatter: NumberFormatter = with(NumberFormatter()) { formatter in
            formatter.numberStyle = .percent
            formatter.maximumFractionDigits = 2
        }

        let model: EarnModel
        let exchangeRate: MoneyValuePair

        func header(title string: String, value moneyValue: MoneyValue) -> some View {
            VStack(alignment: .leading) {
                Text(string)
                    .typography(.caption1)
                    .foregroundColor(.semantic.title)
                Do {
                    try Text(moneyValue.convert(using: exchangeRate).displayString)
                        .typography(.title3)
                        .foregroundColor(.semantic.title)
                }
                Text(moneyValue.displayString)
                    .typography(.caption2)
                    .foregroundColor(.semantic.text)
            }
        }

        var body: some View {
            VStack(alignment: .leading) {
                HStack {
                    AsyncMedia(url: model.currency.logoURL)
                        .frame(width: 32.pt, height: 32.pt)
                    Text(L10n.summaryTitle.interpolating(model.currency.code))
                        .typography(.body2)
                        .foregroundColor(.semantic.title)
                    Spacer()
                    IconButton(icon: .closeCirclev2) {
                        app.post(event: id.article.plain.navigation.bar.button.close.tap[].ref(to: context), context: context)
                    }
                    .frame(width: 24.pt)
                }
                .padding([.leading, .trailing])
                HStack(alignment: .center) {
                    header(
                        title: L10n.balance,
                        value: model.account.balance
                    )
                    Spacer()
                    PrimaryDivider()
                        .frame(height: 60.pt)
                    header(
                        title: L10n.totalEarned,
                        value: model.account.total.rewards
                    )
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding([.leading, .trailing])
                PrimaryDivider()
                ScrollView {
                    VStack {
                        Do {
                            let staked = try model.account.balance - model.account.pending.deposit - model.account.pending.withdrawal
                            TableRow(
                                title: TableRowTitle(L10n.totalStaked),
                                trailingTitle: try TableRowTitle(staked.convert(using: exchangeRate).displayString),
                                trailingByline: TableRowByline(staked.displayString)
                            )
                            PrimaryDivider()
                        }
                        Do {
                            TableRow(
                                title: TableRowTitle(L10n.bonding),
                                trailingTitle: try TableRowTitle(model.account.bonding.deposits.convert(using: exchangeRate).displayString),
                                trailingByline: TableRowByline(model.account.bonding.deposits.displayString)
                            )
                            PrimaryDivider()
                        }
                        TableRow(
                            title: TableRowTitle(L10n.currentRate),
                            trailingTitle: TableRowTitle(My.percentageFormatter.string(from: NSNumber(value: model.rates.rate)) ?? "0%")
                        )
                        PrimaryDivider()
                        TableRow(
                            title: TableRowTitle(L10n.paymentFrequency),
                            trailing: {
                                switch model.limit.reward.frequency {
                                case blockchain.user.earn.product.asset.limit.reward.frequency.daily?:
                                    TableRowTitle(L10n.daily)
                                case blockchain.user.earn.product.asset.limit.reward.frequency.weekly?:
                                    TableRowTitle(L10n.weekly)
                                case blockchain.user.earn.product.asset.limit.reward.frequency.monthly?:
                                    TableRowTitle(L10n.monthly)
                                case _:
                                    EmptyView()
                                }
                            }
                        )
                        PrimaryDivider()
                        TableRow(title: L10n.viewActivity)
                            .tableRowChevron(true)
                            .background(Color.semantic.background)
                            .onTapGesture {
                                app.post(event: id.view.activity.paragraph.row.tap[].ref(to: context), context: context)
                            }
                        PrimaryDivider()
//                        Group {
//                            let inProcess = model.activity.filter(\.state == .processing)
//                            if inProcess.isNotEmpty {
//                                SectionHeader(title: L10n.inProcess)
//                                ForEachWithDivider(inProcess, id: \.id) { item in
//                                    item
//                                }
//                            }
//                        }
                    }
                    AlertCard(
                        title: L10n.withdraw,
                        message: L10n.withdrawDisclaimer
                    ) {
                        SmallSecondaryButton(title: L10n.learnMore) {
                            app.post(event: id.learn.more.paragraph.button.small.secondary.tap[].ref(to: context), context: context)
                        }
                    }
                    .padding()
                }
                HStack {
                    SecondaryButton(title: L10n.withdraw) {
                        app.post(event: id.withdraw.paragraph.button.small.secondary.tap[].ref(to: context), context: context)
                    }
                    .disabled(model.limit.withdraw.is.disabled)
                    PrimaryButton(title: L10n.add) {
                        app.post(event: id.add.paragraph.button.primary.tap[].ref(to: context), context: context)
                    }
                }
                .padding([.leading, .trailing])
            }
            .padding(.top)
        }
    }
}

extension StakingSummaryView {

    @MainActor
    class Object: ObservableObject {

        @Published var model: EarnModel?

        @MainActor
        func start(on app: AppProtocol, in context: Tag.Context) {
            app.publisher(for: blockchain.user.earn.product.asset[].ref(to: context, in: app), as: EarnModel.self)
                .compactMap(\.value)
                .receive(on: DispatchQueue.main)
                .assign(to: &$model)
        }
    }
}

extension EarnActivity: View {

    static let dateFormatter: DateFormatter = with(DateFormatter()) { formatter in
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
    }

    public var body: some View {
        TableRow(
            leading: {
                switch type {
                case .deposit:
                    Icon.deposit.color(.semantic.dark).circle().frame(width: 20.pt)
                case .withdraw:
                    Icon.pending.color(.semantic.dark).circle().frame(width: 20.pt)
                default:
                    Icon.question.color(.semantic.dark).circle().frame(width: 20.pt)
                }
            },
            title: TableRowTitle(currency.code),
            trailing: {
                VStack(alignment: .trailing) {
                    TableRowByline(value.displayString)
                    Text(My.dateFormatter.string(from: date.insertedAt))
                        .typography(.caption1)
                        .foregroundColor(.semantic.text)
                }
            }
        )
    }
}

struct StakingSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        StakingSummaryView(
            exchangeRate: .init(
                base: .one(currency: .ethereum),
                quote: .create(minor: "100234", currency: .fiat(.USD))
            )
        )
        .context(
            [
                blockchain.ux.asset.id: "ETH",
                blockchain.user.earn.product.id: "staking",
                blockchain.user.earn.product.asset.id: "ETH"
            ]
        )
        .app(App.preview)
        .previewDisplayName("Loading")
        StakingSummaryView.Loaded(
            model: .preview,
            exchangeRate: .init(
                base: .one(currency: .ethereum),
                quote: .create(minor: "100000", currency: .fiat(.USD))
            )
        )
        .context(
            [
                blockchain.ux.asset.id: "ETH",
                blockchain.user.earn.product.id: "staking",
                blockchain.user.earn.product.asset.id: "ETH"
            ]
        )
        .app(App.preview)
        .previewDisplayName("Loaded")
    }
}

extension EarnModel {

    static let preview: Self = .init(
        rates: .init(commission: nil, rate: 0.055),
        account: .init(
            balance: .create(minor: "500000000000000000", currency: .crypto(.ethereum)),
            bonding: .init(deposits: .create(minor: "20000000000000000", currency: .crypto(.ethereum))),
            locked: .create(minor: "0", currency: .crypto(.ethereum)),
            pending: .init(
                deposit: .create(minor: "10000000000000000", currency: .crypto(.ethereum)),
                withdrawal: .create(minor: "4000000000000000", currency: .crypto(.ethereum))
            ),
            total: .init(rewards: .create(minor: "10000000000000000", currency: .crypto(.ethereum))),
            unbonding: .init(withdrawals: .create(minor: "0", currency: .crypto(.ethereum)))
        ),
        limit: .init(
            days: .init(bonding: 5, unbonding: 0),
            withdraw: .init(is: .init(disabled: true)),
            reward: .init(
                frequency: blockchain.user.earn.product.asset.limit.reward.frequency.daily[]
            )
        ),
        activity: []
    )
}
