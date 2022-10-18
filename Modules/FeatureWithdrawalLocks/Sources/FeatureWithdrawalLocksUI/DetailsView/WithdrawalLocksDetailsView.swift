// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import FeatureWithdrawalLocksDomain
import Localization
import SwiftUI

struct WithdrawalLocksDetailsView: View {

    let withdrawalLocks: WithdrawalLocks

    @Environment(\.presentationMode) private var presentationMode
    @Environment(\.openURL) private var openURL

    private typealias LocalizationIds = LocalizationConstants.WithdrawalLocks

    var body: some View {
        ZStack(alignment: .top) {
            HStack {
                Spacer()
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Icon.closeCircle
                        .color(.semantic.muted)
                        .frame(height: 24.pt)
                }
            }
            .padding([.trailing])

            VStack {
                Text(
                    String(
                        format: LocalizationIds.onHoldAmountTitle,
                        withdrawalLocks.amount
                    )
                )
                .typography(.title3)
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
                .padding([.top, .leading, .trailing])

                VStack(spacing: 16) {
                    Text(LocalizationIds.holdingPeriodDescription)
                    if !withdrawalLocks.items.isEmpty {
                        Text(LocalizationIds.doesNotLookRightDescription)
                        Text(LocalizationIds.contactSupportTitle)
                            .foregroundColor(.semantic.primary)
                            .onTapGesture {
                                openURL(Constants.contactSupportUrl)
                            }
                    }
                }
                .multilineTextAlignment(.leading)
                .typography(.paragraph1)
                .padding([.leading, .trailing])
                .padding(.top, 8)

                if withdrawalLocks.items.isEmpty {
                    Spacer()

                    Text(LocalizationIds.noLocks)
                        .typography(.paragraph1)
                        .foregroundColor(.semantic.muted)
                        .padding()
                } else {
                    HStack {
                        Text(LocalizationIds.heldUntilTitle.uppercased())
                        Spacer()
                        Text(LocalizationIds.amountTitle.uppercased())
                    }
                    .padding(.top, 32)
                    .padding([.leading, .trailing])
                    .foregroundColor(.semantic.muted)
                    .typography(.overline)

                    PrimaryDivider()

                    ScrollView {
                        ForEach(withdrawalLocks.items) { item in
                            WithdrawalLockItemView(item: item)
                        }
                    }
                }

                Spacer()

                PrimaryButton(
                    title: LocalizationConstants.WithdrawalLocks.learnMoreButtonTitle
                ) {
                    openURL(Constants.withdrawalLocksSupportUrl)
                }
                .padding()
            }
        }
        .padding(.top, 24.pt)
        .navigationBarHidden(true)
    }
}

struct WithdrawalLockItemView: View {
    let item: WithdrawalLocks.Item

    var body: some View {
        HStack {
            Text(item.date)
            Spacer()
            Text(item.amount)
        }
        .foregroundColor(.semantic.body)
        .typography(.paragraph2)
        .frame(height: 44)
        .padding([.leading, .trailing])

        PrimaryDivider()
    }
}

// swiftlint:disable type_name
struct WithdrawalLockDetailsView_PreviewProvider: PreviewProvider {
    static var previews: some View {
        Group {
            WithdrawalLocksDetailsView(
                withdrawalLocks: .init(items: [], amount: "$0")
            )
            WithdrawalLocksDetailsView(
                withdrawalLocks: .init(items: [
                    .init(date: "28 September, 2032", amount: "$100")
                ], amount: "$100")
            )
        }
    }
}
