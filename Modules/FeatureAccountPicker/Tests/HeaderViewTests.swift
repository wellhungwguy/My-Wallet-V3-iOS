// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import FeatureAccountPickerUI
import Localization
import SnapshotTesting
import SwiftUI
import UIComponentsKit
import XCTest

class HeaderViewTests: XCTestCase {

    func testNormal() {
        let view = HeaderView(
            viewModel: .normal(
                title: "Send Crypto Now",
                subtitle: "Choose a Wallet to send cypto from.",
                image: ImageAsset.iconSend.image,
                tableTitle: "Select a Wallet",
                searchable: false
            ),
            searchText: .constant(nil),
            isSearching: .constant(false)
        )
        .fixedSize()

        assertSnapshot(matching: view, as: .image, record: false)
    }

    func testNormalNoImage() {
        let view = HeaderView(
            viewModel: .normal(
                title: "Send Crypto Now",
                subtitle: "Choose a Wallet to send cypto from.",
                image: nil,
                tableTitle: "Select a Wallet",
                searchable: false
            ),
            searchText: .constant(nil),
            isSearching: .constant(false)
        )
        .fixedSize()

        assertSnapshot(matching: view, as: .image, record: false)
    }

    func testNormalNoTableTitle() {
        let view = HeaderView(
            viewModel: .normal(
                title: "Send Crypto Now",
                subtitle: "Choose a Wallet to send cypto from.",
                image: ImageAsset.iconSend.image,
                tableTitle: nil,
                searchable: false
            ),
            searchText: .constant(nil),
            isSearching: .constant(false)
        )
        .fixedSize()

        assertSnapshot(matching: view, as: .image, record: false)
    }

    func testNormalSearch() {
        let view = HeaderView(
            viewModel: .normal(
                title: "Send Crypto Now",
                subtitle: "Choose a Wallet to send cypto from.",
                image: ImageAsset.iconSend.image,
                tableTitle: nil,
                searchable: true
            ),
            searchText: .constant(nil),
            isSearching: .constant(false)
        )
        .fixedSize()

        assertSnapshot(matching: view, as: .image, record: false)
    }

    func testNormalSearchCollapsed() {
        let view = HeaderView(
            viewModel: .normal(
                title: "Send Crypto Now",
                subtitle: "Choose a Wallet to send cypto from.",
                image: ImageAsset.iconSend.image,
                tableTitle: nil,
                searchable: true
            ),
            searchText: .constant("Search"),
            isSearching: .constant(true)
        )
        .animation(nil)
        .frame(width: 375)

        assertSnapshot(matching: view, as: .image, record: false)
    }

    func testSimple() {
        let view = HeaderView(
            viewModel: .simple(
                subtitle: "Subtitle",
                searchable: false
            ),
            searchText: .constant(nil),
            isSearching: .constant(false)
        )
        .fixedSize()

        assertSnapshot(matching: view, as: .image, record: false)
    }

    func testNone() {
        let view = HeaderView(
            viewModel: .none,
            searchText: .constant(nil),
            isSearching: .constant(false)
        )
        .fixedSize()

        assertSnapshot(matching: view, as: .image, record: false)
    }
}
