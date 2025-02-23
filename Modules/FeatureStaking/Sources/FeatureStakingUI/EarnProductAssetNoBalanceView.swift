// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Blockchain
import BlockchainUI
import FeatureStakingDomain
import SwiftUI

@MainActor
public struct EarnProductAssetNoBalanceView: View {

    @BlockchainApp var app
    @Environment(\.context) var context

    let story: L & I_blockchain_ux_earn_type_hub_product_asset_no_balance

    public init(story: L & I_blockchain_ux_earn_type_hub_product_asset_no_balance) {
        self.story = story
    }

    public var body: some View {
        Do {
            let currency: CryptoCurrency = try context.decode(blockchain.user.earn.product.asset.id)
            VStack {
                HStack {
                    Spacer()
                    IconButton(
                        icon: .closeCirclev2,
                        action: {
                            $app.post(event: story.article.plain.navigation.bar.button.close.tap)
                        }
                    )
                    .frame(width: 24.pt)
                }
                Spacer()
                AsyncMedia(url: currency.logoURL)
                    .frame(width: 88.pt, height: 88.pt)
                Spacer()
                Text(L10n.noBalanceTitle.interpolating(currency.code))
                    .typography(.title2)
                    .foregroundColor(.semantic.title)
                Text(L10n.noBalanceMessage.interpolating(currency.code))
                    .typography(.body1)
                    .foregroundColor(.semantic.text)
                    .padding(.bottom)
                Spacer()
                PrimaryButton(
                    title: "Buy \(currency.code)",
                    action: {
                        $app.post(event: story.buy.paragraph.button.primary.tap)
                    }
                )
                MinimalButton(
                    title: "Receive \(currency.code)",
                    action: {
                        $app.post(event: story.receive.paragraph.button.minimal.tap)
                    }
                )
            }
            .multilineTextAlignment(.center)
            .batch(
                .set(story.article.plain.navigation.bar.button.close.tap.then.close, to: true),
                .set(story.buy.paragraph.button.primary.tap.then.close, to: true),
                .set(story.buy.paragraph.button.primary.tap.then.emit, to: blockchain.ux.asset[currency.code].buy),
                .set(story.receive.paragraph.button.minimal.tap.then.close, to: true),
                .set(story.receive.paragraph.button.minimal.tap.then.emit, to: blockchain.ux.asset[currency.code].receive)
            )
        } catch: { _ in
            EmptyView()
        }
        .padding()
        .post(lifecycleOf: story.article.plain)
    }
}

let percentageFormatter: NumberFormatter = with(NumberFormatter()) { formatter in
    formatter.numberStyle = .percent
    formatter.maximumFractionDigits = 2
}
