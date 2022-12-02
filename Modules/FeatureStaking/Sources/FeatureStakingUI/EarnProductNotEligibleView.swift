// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainUI
import FeatureStakingDomain
import SwiftUI

@MainActor
public struct EarnProductNotEligibleView: View {

    @BlockchainApp var app
    @Environment(\.context) var context

    let story: L & I_blockchain_ux_earn_type_hub_product_not_eligible
    let product: EarnProduct

    public init(story: L & I_blockchain_ux_earn_type_hub_product_not_eligible, product: EarnProduct) {
        self.story = story
        self.product = product
    }

    public var body: some View {
        VStack {
            HStack {
                Spacer()
                IconButton(
                    icon: .closeCirclev2,
                    action: {
                        app.post(event: story.article.plain.navigation.bar.button.close.tap[].ref(to: context), context: context)
                    }
                )
                .frame(width: 24.pt)
            }
            Spacer()
            Icon.interestCircle
                .color(.semantic.title)
                .circle(backgroundColor: .semantic.light)
                .frame(width: 88.pt, height: 88.pt)
            Spacer()
            Text(L10n.notEligibleTitle)
                .typography(.title2)
                .foregroundColor(.semantic.title)
                .padding(.bottom)
            Text(L10n.notEligibleMessage.interpolating(product.title))
                .typography(.body1)
                .foregroundColor(.semantic.text)
                .padding(.bottom)
                .fixedSize(horizontal: false, vertical: true)
            Spacer()
            MinimalButton(
                title: L10n.goBack,
                action: {
                    app.post(event: story.go.back.paragraph.button.minimal.tap[].ref(to: context), context: context)
                }
            )
        }
        .multilineTextAlignment(.center)
        .padding()
        .onAppear {
            app.post(event: story.article.plain.lifecycle.event.did.enter[].ref(to: context), context: context)
        }
        .onDisappear {
            app.post(event: story.article.plain.lifecycle.event.did.exit[].ref(to: context), context: context)
        }
        .batch(
            .set(story.article.plain.navigation.bar.button.close.tap.then.close, to: true),
            .set(story.go.back.paragraph.button.minimal.tap.then.close, to: true)
        )
    }
}
