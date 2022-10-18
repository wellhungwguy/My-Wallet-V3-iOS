// Copyright © Blockchain Luxembourg S.A. All rights reserved.
import BlockchainComponentLibrary
import SwiftUI

struct AnnouncementCardExamples: View {
    var body: some View {
        AnnouncementCard(
            title: "New Asset",
            message: "Dogecoin (DOGE) is now available on Blockchain.",
            onCloseTapped: {},
            leading: {
                Icon.wallet
                    .color(.semantic.gold)
            }
        )
    }
}

struct AnnouncementCardExamples_Previews: PreviewProvider {
    static var previews: some View {
        AnnouncementCardExamples()
    }
}
