// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import Localization
import SwiftUI

struct PatriotActView: View {

    private typealias L10n = LocalizationConstants.CardIssuing.Order.PatriotAct

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.padding3) {
            Text(L10n.title)
                .typography(.title3)
                .multilineTextAlignment(.leading)
            VStack(alignment: .leading) {
                Text(L10n.Article1.title)
                    .typography(.paragraph1)
                    .multilineTextAlignment(.leading)
                Text(L10n.Article1.description)
                    .typography(.paragraph1)
                    .foregroundColor(.semantic.body)
                    .multilineTextAlignment(.leading)
            }
            VStack(alignment: .leading) {
                Text(L10n.Article2.title)
                    .typography(.paragraph1)
                    .multilineTextAlignment(.leading)
                Text(L10n.Article2.description)
                    .typography(.paragraph1)
                    .foregroundColor(.semantic.body)
                    .multilineTextAlignment(.leading)
            }
            Spacer()
        }
        .padding(Spacing.padding3)
        .primaryNavigation(title: L10n.navigationTitle)
    }
}

#if DEBUG
struct PatriotAct_Previews: PreviewProvider {
    static var previews: some View {
        PrimaryNavigationView {
            PatriotActView()
        }
    }
}
#endif
