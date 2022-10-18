// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import SwiftUI

@MainActor
struct RowExamplesView: View {

    private let data: NavigationLinkProviderList = [
        "Rows": [
            NavigationLinkProvider(view: TableRowExamplesView(), title: "TableRow"),
            NavigationLinkProvider(view: PrimaryRowExamplesView(), title: "PrimaryRow (old)"),
            NavigationLinkProvider(view: BalanceRowExamplesView(), title: "BalanceRow")
        ]
    ]

    var body: some View {
        NavigationLinkProviderView(data: data)
    }
}

struct RowExamplesView_Previews: PreviewProvider {
    static var previews: some View {
        PrimaryNavigationView {
            RowExamplesView()
        }
    }
}
