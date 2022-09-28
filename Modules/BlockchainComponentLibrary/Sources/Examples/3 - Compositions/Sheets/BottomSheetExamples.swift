// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import SwiftUI

struct BottomSheetExamples: View {

    @State var isPresented: Bool = true

    var body: some View {
        Button("Tap to open") {
            withAnimation(.spring()) {
                isPresented.toggle()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .bottomSheet(isPresented: $isPresented.animation(.spring())) {
            ForEach(1..<6) { i in
                PrimaryRow(
                    title: "\(i)",
                    subtitle: (0...i).map(String.init).joined(separator: ", "),
                    leading: {
                        Icon.allIcons
                            .randomElement()!
                            .circle()
                            .color(.semantic.primary)
                            .frame(maxHeight: 24.pt)
                    },
                    action: {}
                )
                .frame(maxHeight: 8.vh)
                PrimaryDivider()
            }
            HStack {
                PrimaryButton(title: "Buy", action: {})
                SecondaryButton(title: "Sell", action: {})
            }
            .padding(Spacing.padding())
        }
        .ignoresSafeArea()
    }
}

struct BottomSheetExamples_Previews: PreviewProvider {
    static var previews: some View {
        BottomSheetExamples()
    }
}
