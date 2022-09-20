// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import XCTest

// swiftlint:disable all

final class QRCodeScannerViewModelTests: XCTestCase {

    // var subject: QRCodeScannerViewModel!

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        // subject = nil
        super.tearDown()
    }

    // TODO:
    // * Fix these tests
    //    func test_setup() {
    //        XCTAssertNotNil(subject.videoPreviewLayer)
    //        XCTAssertEqual(subject.loadingText, "loadingText")
    //        XCTAssertEqual(subject.headerText, "headerText")
    //    }
    //
    //    func testCloseButtonPressed() {
    //        let expecationStopReadingQRCodeCalled = expectation(description: "stopReadingQRCode called")
    //        let expecationScanningStoppedCalled = expectation(description: "scanningStopped called")
    //
    //        XCTAssertEqual(scanner.stopReadingQRCodeCallCount, 0)
    //        scanner.stopReadingQRCodeCalled = {
    //            XCTAssertEqual(self.scanner.stopReadingQRCodeCallCount, 1)
    //            expecationStopReadingQRCodeCalled.fulfill()
    //        }
    //
    //        subject.scanningStopped = {
    //            expecationScanningStoppedCalled.fulfill()
    //        }
    //
    //        subject.closeButtonPressed()
    //        scanner.delegate?.didStopScanning()
    //
    //        waitForExpectations(timeout: 5)
    //    }
    //
    //    func testStartReadingQRCode() {
    //        let expecationStopReadingQRCodeCalled = expectation(description: "stopReadingQRCode called")
    //        let expecationScanningStartedCalled = expectation(description: "scanningStarted called")
    //
    //        XCTAssertEqual(scanner.startReadingQRCodeCallCount, 0)
    //        scanner.startReadingQRCodeCalled = {
    //            XCTAssertEqual(self.scanner.startReadingQRCodeCallCount, 1)
    //            expecationStopReadingQRCodeCalled.fulfill()
    //        }
    //
    //        subject.scanningStarted = {
    //            expecationScanningStartedCalled.fulfill()
    //        }
    //
    //        subject.startReadingQRCode(from: scannableArea)
    //        scanner.delegate?.didStartScanning()
    //
    //        waitForExpectations(timeout: 5)
    //    }
    //
    //    func testHandleDismissCompleted() {
    //        let expectationParseCalled = expectation(description: "parse called")
    //        let expectationScanCompleteCalled = expectation(description: "scanComplete called")
    //
    //        subject = QRCodeScannerViewModel(
    //            types: [.cryptoTarget(nil), .deepLink],
    //            additionalParsingOptions: .strict,
    //            textViewModel: textViewModel,
    //            supportsCameraRoll: false,
    //            scanner: scanner,
    //            completed: { result in
    //                guard case .success(let model) = result else {
    //                    XCTFail("the completion block is expected to be called with success")
    //                    return
    //                }
    ////                XCTAssertEqual(model, MockQRCodeScannerParser.Model(value: "ScanValue"))
    //                expectationParseCalled.fulfill()
    //            },
    //            deepLinkHandler: MockDeepLinkHandler(),
    //            deepLinkRouter: MockDeepLinkRouter()
    //        )
    //
    //        subject.scanComplete = { result in
    //            guard case .success(let scannedString) = result else {
    //                XCTFail("the completion block is expected to be called with success")
    //                return
    //            }
    ////            XCTAssertEqual(scannedString, "ScanValue")
    //            expectationScanCompleteCalled.fulfill()
    //        }
    //
    ////        scanner.delegate?.scanComplete(with: .success("ScanValue"))
    ////        subject.handleDismissCompleted(with: .success("ScanValue"))
    //
    //        waitForExpectations(timeout: 5)
    //    }
}
