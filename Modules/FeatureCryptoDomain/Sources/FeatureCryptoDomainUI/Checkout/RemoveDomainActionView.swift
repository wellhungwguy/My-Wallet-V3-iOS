// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import FeatureCryptoDomainDomain
import Localization
import SwiftUI

struct RemoveDomainActionView: View {

    private typealias LocalizedString = LocalizationConstants.FeatureCryptoDomain.DomainCheckout.RemoveDomain
    private typealias Accessibility = AccessibilityIdentifiers.RemoveDomainBottomSheet

    @Binding var domain: SearchDomainResult?
    @Binding var isShown: Bool
    var removeButtonTapped: () -> Void

    var body: some View {
        VStack(alignment: .center, spacing: Spacing.padding2) {
            Icon.delete
                .color(.semantic.primary)
                .frame(width: 54, height: 54)
                .accessibility(identifier: Accessibility.removeIcon)
            Text(String(format: LocalizedString.removeTitle, domain?.domainName ?? ""))
                .typography(.title3)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.bottom, Spacing.padding3)
                .accessibility(identifier: Accessibility.removeTitle)
            DestructivePrimaryButton(
                title: LocalizedString.removeButton,
                action: removeButtonTapped
            )
            .accessibility(identifier: Accessibility.removeButton)
            MinimalButton(title: LocalizedString.nevermindButton) {
                withAnimation {
                    isShown.toggle()
                }
            }
            .padding(.bottom, Spacing.padding3)
            .accessibility(identifier: Accessibility.nevermindButton)
        }
        .multilineTextAlignment(.center)
        .padding(Spacing.padding3)
    }
}

struct RemoveDomainActionView_Previews: PreviewProvider {
    static var previews: some View {
        RemoveDomainActionView(
            domain: .constant(
                SearchDomainResult(
                    domainName: "example.blockchain",
                    domainType: .free,
                    domainAvailability: .availableForFree
                )
            ),
            isShown: .constant(true),
            removeButtonTapped: {}
        )
    }
}
