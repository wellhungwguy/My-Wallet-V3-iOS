// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import SwiftUI

public struct DefiBuyCryptoMessageView: View {
    @Environment(\.presentationMode) private var presentationMode
    let onOpenTradingModeTap: () -> Void

    public init(onOpenTradingModeTap: @escaping () -> Void) {
        self.onOpenTradingModeTap = onOpenTradingModeTap
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: Spacing.padding2) {

            Text(
                "We don’t support buying crypto into your Private Key Wallet at this time. " +
                "You can buy from your Trading Account and send to your Private Key Wallet."
            )
            .typography(.body1)
            .padding(.horizontal, Spacing.padding3)

            PrimaryButton(
                title: "Open Trading Account",
                isLoading: false
            ) {
                presentationMode.wrappedValue.dismiss()
                onOpenTradingModeTap()
            }
                          .padding(.horizontal, Spacing.padding3)
        }
        .frame(minHeight: 200)
    }
}

struct DefiBuyCryptoMessageView_Previews: PreviewProvider {
    static var previews: some View {
        DefiBuyCryptoMessageView(onOpenTradingModeTap: {})
    }
}
