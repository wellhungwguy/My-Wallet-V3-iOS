// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import SwiftUI

struct PrimaryPickerExamples: View {
    enum Options: Hashable {
        case begin
        case end
        case trailingNoPicker
        case noPicker
    }

    @State var date = Date()
    @State var selection: Options?

    var body: some View {
        VStack {
            PrimaryPicker(
                selection: $selection,
                rows: [
                    .row(
                        title: "Begins",
                        identifier: .begin,
                        trailing: {
                            TagView(
                                text: "\(date)",
                                variant: selection == .begin ? .infoAlt : .default
                            )
                        },
                        picker: {
                            DatePicker(
                                "Start Date",
                                selection: $date,
                                displayedComponents: [.date]
                            )
                            .datePickerStyle(GraphicalDatePickerStyle())
                            .padding(.top, 8)
                        }
                    ),
                    .row(
                        title: "Ends",
                        identifier: .end,
                        trailing: {
                            TagView(
                                text: "\(date)",
                                variant: selection == .end ? .infoAlt : .default
                            )
                        },
                        picker: {
                            DatePicker(
                                "End Date",
                                selection: $date,
                                displayedComponents: [.date]
                            )
                            .datePickerStyle(GraphicalDatePickerStyle())
                            .padding(.top, 8)
                        }
                    ),
                    .row(
                        title: "Trailing, no picker",
                        identifier: .trailingNoPicker,
                        trailing: {
                            Icon.chevronDown
                                .color(.semantic.muted)
                                .frame(height: 24)
                        }
                    ),
                    .row(
                        title: "No Picker or Trailing",
                        identifier: .noPicker
                    )
                ]
            )

            Spacer()
        }
        .padding(Spacing.padding())
        .bottomSheet(
            isPresented: Binding(
                get: { selection == .trailingNoPicker },
                set: { _ in selection = nil }
            )
        ) {
            Text("Sub-Options")
        }
        .background(
            PrimaryNavigationLink(
                destination: Text("Tapped \"No Picker or Trailing\""),
                isActive: Binding(
                    get: { selection == .noPicker },
                    set: { _ in selection = nil }
                ),
                label: EmptyView.init
            )
        )
    }
}

struct PrimaryPickerExamples_Previews: PreviewProvider {
    static var previews: some View {
        PrimaryNavigationView {
            PrimaryPickerExamples()
                .primaryNavigation(title: "Picker")
        }
    }
}
