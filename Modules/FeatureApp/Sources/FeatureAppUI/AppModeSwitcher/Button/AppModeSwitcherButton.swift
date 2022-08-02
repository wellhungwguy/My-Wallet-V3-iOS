// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import Foundation
import SwiftUI

public struct AppModeSwitcherButton: View {
    var isDefiMode: Bool = false
    private let action: () -> Void

    public init(
        isDefiMode: Bool = false,
        action: @escaping () -> Void
    ) {
        self.isDefiMode = isDefiMode
        self.action = action
    }

    public var body: some View {
        HStack {
            if isDefiMode {
                Icon
                    .wallet
                    .accentColor(.semantic.defi)
                    .frame(width: 20, height: 20)
            } else {
                Icon
                    .portfolio
                    .accentColor(.semantic.primary)
                    .frame(width: 20, height: 20)
            }

            Text(isDefiMode ? "DeFi Wallet" : "Brokerage")
                .typography(.body1)
                .foregroundColor(Color.WalletSemantic.title)

            Icon
                .chevronDown
                .accentColor(.semantic.muted)
                .frame(width: 16, height: 16)
        }
        .frame(width: 158, height: 32)
        .background(Color.WalletSemantic.light)
        .cornerRadius(100)
        .onTapGesture {
            action()
        }
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        AppModeSwitcherButton(action: {})
    }
}
