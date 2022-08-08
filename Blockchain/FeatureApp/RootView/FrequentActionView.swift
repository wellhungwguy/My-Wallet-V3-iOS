//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import Localization
import SwiftUI
import ToolKit

struct FrequentAction: Hashable, Identifiable, Codable {

    var id: String { tag.id }
    let tag: Tag
    let name: String
    let icon: Icon
    let description: String
}

struct FrequentActionView: View {

    @BlockchainApp var app
    @Environment(\.context) var context

    var list: [FrequentAction]
    var buttons: [FrequentAction]

    init(
        list: [FrequentAction],
        buttons: [FrequentAction]
    ) {
        self.list = list
        self.buttons = buttons
    }

    var body: some View {
        ForEach(list.indexed(), id: \.element) { index, item in
            VStack(alignment: .leading, spacing: 0) {
                if index != list.startIndex {
                    PrimaryDivider()
                        .padding(.leading, 72.pt)
                }
                PrimaryRow(
                    title: item.name.localized(),
                    subtitle: item.description.localized(),
                    leading: {
                        item.icon.circle()
                            .accentColor(.semantic.primary)
                            .frame(width: 32.pt)
                    },
                    action: {
                        app.post(event: item.tag, context: context)
                    }
                )
                .identity(item.tag)
            }
        }
        HStack(spacing: 8.pt) {
            ForEach(buttons) { button in
                switch button.tag {
                case blockchain.ux.frequent.action.buy:
                    PrimaryButton(
                        title: button.name.localized(),
                        leadingView: { button.icon },
                        action: {
                            app.post(event: button.tag, context: context)
                        }
                    )
                    .identity(button.tag)
                default:
                    SecondaryButton(
                        title: button.name.localized(),
                        leadingView: { button.icon },
                        action: {
                            app.post(event: button.tag, context: context)
                        }
                    )
                    .identity(button.tag)
                }
            }
        }
        .padding([.top, .bottom])
        .padding([.leading, .trailing], 24.pt)
        .onAppear {
            app.post(event: blockchain.ux.frequent.action, context: context)
        }
    }
}
