// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import SwiftUI

struct IconsExamplesView: View {
    let columns = Array(
        repeating: GridItem(.fixed(110)),
        count: 3
    )

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, alignment: .center, spacing: 48) {
                ForEach(Icon.allIcons, id: \.name) { icon in
                    VStack {
                        icon
                            .color(.semantic.muted)
                            .frame(width: 24)

                        icon.circle()
                            .color(.semantic.muted)
                            .frame(width: 32)

                        Text(icon.name)
                            .typography(.caption2)
                    }
                }
            }
        }
    }
}

struct IconsExamplesView_Previews: PreviewProvider {
    static var previews: some View {
        IconsExamplesView()
    }
}
