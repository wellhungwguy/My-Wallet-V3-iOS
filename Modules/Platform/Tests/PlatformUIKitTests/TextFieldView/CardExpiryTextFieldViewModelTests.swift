// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import PlatformUIKit

import RxBlocking
import RxSwift
import ToolKit
@testable import ToolKitMock
import XCTest

final class CardExpiryTextFieldViewModelTests: XCTestCase {

    private var viewModel: CardExpiryTextFieldViewModel!

    override func setUp() {
        super.setUp()
        viewModel = CardExpiryTextFieldViewModel(
            messageRecorder: MockMessageRecorder()
        )
    }

    func testDayAutoCorrection1() throws {
        _ = viewModel.editIfNecessary("1", operation: .addition)
        _ = viewModel.editIfNecessary("12", operation: .addition)
        let text = try viewModel.text.toBlocking().first()!
        XCTAssertEqual(text, "12/")

        let isValid = try viewModel.state.toBlocking().first()!.isValid
        XCTAssertFalse(isValid)
    }

    func testAdditionOfYear() throws {
        _ = viewModel.editIfNecessary("12/9", operation: .addition)
        var text = try viewModel.text.toBlocking().first()!
        XCTAssertEqual(text, "12/9")

        var isValid = try viewModel.state.toBlocking().first()!.isValid
        XCTAssertFalse(isValid)

        _ = viewModel.editIfNecessary("12/92", operation: .addition)
        text = try viewModel.text.toBlocking().first()!
        XCTAssertEqual(text, "12/92")

        isValid = try viewModel.state.toBlocking().first()!.isValid
        XCTAssertTrue(isValid)
    }

    func testDeletionAfterSlash() throws {
        _ = viewModel.editIfNecessary("12", operation: .deletion)
        let text = try viewModel.text.toBlocking().first()!
        XCTAssertEqual(text, "1")

        let isValid = try viewModel.state.toBlocking().first()!.isValid
        XCTAssertFalse(isValid)
    }

    func testFullyFormattedDate() throws {
        _ = viewModel.editIfNecessary("12/23", operation: .addition)
        let text = try viewModel.text.toBlocking().first()!
        XCTAssertEqual(text, "12/23")

        let isValid = try viewModel.state.toBlocking().first()!.isValid
        XCTAssertTrue(isValid)
    }
}
