// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct LayoutAttributes: Equatable {

    public let minimumInterItemSpacing: CGFloat
    public let minimumLineSpacing: CGFloat
    public let sectionInsets: UIEdgeInsets

    public static let exchangeDetail = LayoutAttributes(
        minimumInterItemSpacing: 0.0,
        minimumLineSpacing: 8.0,
        sectionInsets: UIEdgeInsets(top: 0.0, left: 16.0, bottom: 0.0, right: 16.0)
    )

    public static let exchangeOverview = LayoutAttributes(
        minimumInterItemSpacing: 0.0,
        minimumLineSpacing: 8.0,
        sectionInsets: UIEdgeInsets(top: 16.0, left: 16.0, bottom: 0.0, right: 16.0)
    )

    public static let tiersOverview = LayoutAttributes(
        minimumInterItemSpacing: 0.0,
        minimumLineSpacing: 16.0,
        sectionInsets: UIEdgeInsets(top: 16.0, left: 16.0, bottom: 0.0, right: 16.0)
    )

    public static let horizontal = LayoutAttributes(
        minimumInterItemSpacing: 0.0,
        minimumLineSpacing: 0.0,
        sectionInsets: UIEdgeInsets(top: 0.0, left: 16.0, bottom: 0.0, right: 0.0)
    )

    public static let vertical = LayoutAttributes(
        minimumInterItemSpacing: 0.0,
        minimumLineSpacing: 0.0,
        sectionInsets: UIEdgeInsets.zero
    )

    public static let outer = LayoutAttributes(
        minimumInterItemSpacing: 0,
        minimumLineSpacing: 0,
        sectionInsets: .zero
    )

    public static func == (lhs: LayoutAttributes, rhs: LayoutAttributes) -> Bool {
        guard lhs.minimumInterItemSpacing == rhs.minimumInterItemSpacing else { return false }
        guard lhs.minimumLineSpacing == rhs.minimumLineSpacing else { return false }
        guard lhs.sectionInsets == rhs.sectionInsets else { return false }

        return true
    }
}
