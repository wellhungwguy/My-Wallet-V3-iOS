import SwiftUI

public struct BottomBarItemView<Selection>: View where Selection: Hashable {
    public let isSelected: Bool
    public let item: BottomBarItem<Selection>

    public var body: some View {
        VStack {
            Group {

                ZStack {
                    item
                        .selectedIcon
                        .foregroundColor(.WalletSemantic.title)
                        .opacity(isSelected ? 1 : 0)

                    item
                        .unselectedIcon
                        .foregroundColor(.WalletSemantic.title)
                        .opacity(isSelected ? 0 : 1)
                }
            }
            .frame(width: 24, height: 24)
            Text(item.title)
                .foregroundColor(.WalletSemantic.title)
                .typography(.micro)
                .fixedSize()
        }
        .padding(.vertical, 8)
    }
}
