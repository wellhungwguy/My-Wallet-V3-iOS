// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

/// PageControl from the Figma Component Library.
///
///
/// # Usage:
///
/// The PageControl can be initialized with any number of elements.
/// Every control parameter will be represented as a circular indicator on the PageControl.
/// The selection parameter indicates the initial selected control.
/// The selected control can be set through an indicator tap.
///
/// `PageControl(
///     controls: ["first", "second", "third"],
///     selection: $selected
/// )`
///
/// - Version: 1.0.1
///
/// # Figma
///
///  [Controls](https://www.figma.com/file/nlSbdUyIxB64qgypxJkm74/03---iOS-%7C-Shared?node-id=6%3A510)
public struct PageControl<Selection: Hashable>: View {

    private var items: [Item]

    @Binding private var selection: Selection

    /// Create a PageControl view with any number of indicators and an initial selection state.
    /// - Parameter controls: Elements that will be represented as indicators on the PageControl. Every control element will have its indicator.
    /// - Parameter selection: Binding for `selection` from `contrls` for the currently selected element.
    public init(
        controls: [Selection],
        selection: Binding<Selection>
    ) {
        self.items = controls.map { Item(identifier: $0) }
        _selection = selection
    }

    public var body: some View {
        HStack(spacing: 0) {
            ForEach(items) { item in
                Indicator(
                    isOn: Binding(
                        get: {
                            selection == item.id
                        },
                        set: { _ in
                            selection = item.id
                        }
                    )
                )
            }
        }
        .padding(.vertical, 15)
        .padding(.horizontal, 20)
    }
}

extension PageControl {

    struct Indicator: View {

        @Binding private var isOn: Bool

        init(isOn: Binding<Bool>) {
            _isOn = isOn
        }

        var body: some View {
            ZStack {
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: 18, height: 18)
                Circle()
                    .fill(
                        isOn ? Color.semantic.primary : .semantic.medium
                    )
                    .frame(width: 8, height: 8)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                isOn.toggle()
            }
        }
    }
}

extension PageControl {

    struct Item: Identifiable {
        let identifier: Selection
        var id: Selection { identifier }
    }
}

struct PageControl_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            PreviewController(
                items: ["first", "second", "third", "fourth"],
                selection: "first"
            )
            .previewLayout(.sizeThatFits)
            .previewDisplayName("PageControl")

            TabController()
                .frame(width: 320, height: 200)
                .previewLayout(.sizeThatFits)
                .previewDisplayName("In use")
        }
        .padding()
    }

    struct PreviewController<Item: Hashable>: View {
        let items: [Item]
        @State var selection: Item

        init(
            items: [Item],
            selection: Item
        ) {
            self.items = items
            _selection = State(initialValue: selection)
        }

        var body: some View {
            PageControl(
                controls: items,
                selection: $selection
            )
        }
    }

    struct TabController: View {

        let controls: [Color] = [
            Color.red,
            Color.blue,
            Color.green
        ]
        @State var selection: Color

        init() {
            _selection = State(initialValue: controls[0])
        }

        var body: some View {
            ZStack {
                HStack(spacing: 0) {
                    controlView(control: controls[0])
                    controlView(control: controls[1])
                    controlView(control: controls[2])
                }
                VStack {
                    Spacer()
                    PageControl(
                        controls: controls,
                        selection: $selection
                    )
                }
            }
        }

        @ViewBuilder private func controlView(control: Color) -> some View {
            control
                .onTapGesture { selection = control }
                .overlay(
                    Text("selected")
                        .foregroundColor(.white)
                        .opacity(selection == control ? 1 : 0)
                )
        }
    }
}
