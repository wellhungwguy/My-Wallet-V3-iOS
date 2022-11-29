// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import SwiftUI

struct MultiAppDebugView: View {
    @BlockchainApp var app
    var body: some View {
            VStack {
                PrimaryRow(title: "All Assets Screen") {
                    app.post(event: blockchain.ux.multiapp.present.allAssetsScreen)
                }
                Spacer()
            }
            .padding(.horizontal)
    }
}

struct MultiAppDebugView_Previews: PreviewProvider {
    static var previews: some View {
        MultiAppDebugView()
    }
}
