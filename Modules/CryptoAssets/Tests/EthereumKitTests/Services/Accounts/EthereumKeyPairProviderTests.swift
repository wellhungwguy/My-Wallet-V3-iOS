// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import EthereumKit
@testable import EthereumKitMock
@testable import PlatformKitMock
import RxSwift
import RxTest
import XCTest

final class EthereumKeyPairProviderTests: XCTestCase {

    var scheduler: TestScheduler!
    var disposeBag: DisposeBag!
    var mnemonicAccess: MnemonicAccessMock!
    var deriver: EthereumKeyPairDeriver!
    var subject: EthereumKeyPairProvider!

    override func setUp() {
        super.setUp()

        scheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
        mnemonicAccess = MnemonicAccessMock()
        mnemonicAccess.underlyingMnemonic = .just(MockEthereumWalletTestData.mnemonic)
        deriver = EthereumKeyPairDeriver()
        subject = EthereumKeyPairProvider(
            mnemonicAccess: mnemonicAccess,
            deriver: deriver
        )
    }

    override func tearDown() {
        scheduler = nil
        disposeBag = nil
        deriver = nil
        subject = nil
        super.tearDown()
    }

    func test_load_key_pair() {
        // Arrange
        let expectedKeyPair = MockEthereumWalletTestData.keyPair

        let sendObservable: Observable<EthereumKeyPair> = subject.keyPair
            .asObservable()

        // Act
        let result: TestableObserver<EthereumKeyPair> = scheduler
            .start { sendObservable }

        // Assert
        let expectedEvents: [Recorded<Event<EthereumKeyPair>>] = Recorded.events(
            .next(
                200,
                expectedKeyPair
            ),
            .completed(200)
        )

        XCTAssertEqual(result.events, expectedEvents)
    }
}
