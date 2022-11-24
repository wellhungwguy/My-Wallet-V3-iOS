// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import Localization
import SwiftUI
import UIComponentsKit

struct InterestAccountListErrorView: View {

    private typealias LocalizationId = LocalizationConstants.Interest.Screen.OverviewError

    private let buttonTapped: () -> Void

    init(action: @escaping () -> Void) {
        self.buttonTapped = action
    }

    var body: some View {
        PrimaryNavigationView {
            VStack(alignment: .center, spacing: 8.0) {
                Text(LocalizationId.title)
                    .textStyle(.title)
                VStack(alignment: .center, spacing: 4.0) {
                    Text(LocalizationId.description)
                        .textStyle(.subheading)
                        .multilineTextAlignment(.center)
                    Text(LocalizationId.body)
                        .textStyle(.subheading)
                        .multilineTextAlignment(.center)
                }
                .padding([.leading, .trailing], 16.0)
                Image("sb-intro-bg-theme", bundle: .platformUIKit)
                Spacer()
                PrimaryButton(
                    title: LocalizationId.action,
                    action: buttonTapped
                )
                .padding([.leading, .trailing], 24.0)
            }
            .whiteNavigationBarStyle()
            .navigationTitle(LocalizationId.navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct InterestAccountListErrorView_Previews: PreviewProvider {
    static var previews: some View {
        InterestAccountListErrorView(action: {})
    }
}
