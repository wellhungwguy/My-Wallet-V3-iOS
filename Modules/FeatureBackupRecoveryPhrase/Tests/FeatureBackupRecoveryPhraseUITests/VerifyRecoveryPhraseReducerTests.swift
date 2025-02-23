// Copyright © Blockchain Luxembourg S.A. All rights reserved.

 import Foundation

 import ComposableArchitecture
 import ComposableNavigation
 import Errors
 import FeatureBackupRecoveryPhraseDomain
 @testable import FeatureBackupRecoveryPhraseUI
 import XCTest

class VerifyRecoveryPhraseReducerTest: XCTestCase {
    private var testStore: TestStore<
        VerifyRecoveryPhraseState,
        VerifyRecoveryPhraseAction,
        VerifyRecoveryPhraseState,
        VerifyRecoveryPhraseAction,
        VerifyRecoveryPhraseEnvironment
    >!

    private let mainScheduler: TestSchedulerOf<DispatchQueue> = DispatchQueue.test
     private var recpveryPhraseRepositoryMock: RecoveryPhraseRepositoryMock!
     private var recoveryPhraseVerifyingServiceMock: RecoveryPhraseVerifyingServiceMock!

    override func setUpWithError() throws {
        try super.setUpWithError()
        recpveryPhraseRepositoryMock = RecoveryPhraseRepositoryMock()
        recoveryPhraseVerifyingServiceMock = RecoveryPhraseVerifyingServiceMock()

        testStore = TestStore(
            initialState: .init(),
            reducer: VerifyRecoveryPhraseModule.reducer,
            environment: VerifyRecoveryPhraseEnvironment(
                mainQueue: mainScheduler.eraseToAnyScheduler(),
                recoveryPhraseRepository: recpveryPhraseRepositoryMock,
                recoveryPhraseService: recoveryPhraseVerifyingServiceMock,
                onNext: {}
            )
        )
    }

    override func tearDownWithError() throws {
        recpveryPhraseRepositoryMock = nil
        recoveryPhraseVerifyingServiceMock = nil
        testStore = nil
        try super.tearDownWithError()
    }

        func test_fetchWords_on_startup() {
            // GIVEN
            let mockedWords = MockGenerator.mockedWords
            recoveryPhraseVerifyingServiceMock.recoveryPhraseComponentsSubject.send(mockedWords)
            // WHEN
            testStore.send(.onAppear)
            mainScheduler.advance()
            // THEN
            var generator = testStore.environment.generator
            XCTAssertTrue(recoveryPhraseVerifyingServiceMock.recoveryPhraseComponentsCalled)
            testStore.receive(.onRecoveryPhraseComponentsFetchSuccess(mockedWords)) {
                $0.availableWords = mockedWords
                $0.shuffledAvailableWords = mockedWords.shuffled(using: &generator)
            }
            recoveryPhraseVerifyingServiceMock.recoveryPhraseComponentsSubject.send(completion: .finished)
            mainScheduler.advance()
        }

    func test_onSelectedWord_Tap() {
        // GIVEN
        var mockedWords = MockGenerator.mockedWords
        testStore = TestStore(
            initialState: .init(
                selectedWords: mockedWords
            ),
            reducer: VerifyRecoveryPhraseModule.reducer,
            environment: VerifyRecoveryPhraseEnvironment(
                mainQueue: mainScheduler.eraseToAnyScheduler(),
                recoveryPhraseRepository: recpveryPhraseRepositoryMock,
                recoveryPhraseService: recoveryPhraseVerifyingServiceMock,
                onNext: {}
            )
        )
        // WHEN
        // THEN
        testStore.send(.onSelectedWordTap(mockedWords.removeFirst())) {
            $0.selectedWords = mockedWords
        }
    }

    func test_onAvailableWord_Tap() {
        var mockedWords = MockGenerator.mockedWords
        testStore = TestStore(
            initialState: .init(
                selectedWords: []
            ),
            reducer: VerifyRecoveryPhraseModule.reducer,
            environment: VerifyRecoveryPhraseEnvironment(
                mainQueue: mainScheduler.eraseToAnyScheduler(),
                recoveryPhraseRepository: recpveryPhraseRepositoryMock,
                recoveryPhraseService: recoveryPhraseVerifyingServiceMock,
                onNext: {}
            )
        )

        let firstWord = mockedWords.removeFirst()
        testStore.send(.onAvailableWordTap(firstWord)) {
            $0.selectedWords = [firstWord]
        }
    }

    func test_onLastAvailableWord_Tap() {
        let allWords = MockGenerator.mockedWords
        var selectedWords = MockGenerator.mockedWords
        let lastWord = selectedWords.removeLast()
        testStore = TestStore(
            initialState: .init(
                selectedWords: selectedWords,
                availableWords: allWords
            ),
            reducer: VerifyRecoveryPhraseModule.reducer,
            environment: VerifyRecoveryPhraseEnvironment(
                mainQueue: mainScheduler.eraseToAnyScheduler(),
                recoveryPhraseRepository: recpveryPhraseRepositoryMock,
                recoveryPhraseService: recoveryPhraseVerifyingServiceMock,
                onNext: {}
            )
        )

        testStore.send(.onAvailableWordTap(lastWord)) {
            $0.selectedWords = allWords
            $0.backupPhraseStatus = .readyToVerify
        }
    }

    func test_onVerify_Tap_success() {
        let mockedWords = MockGenerator.mockedWords
        testStore = TestStore(
            initialState: .init(
                selectedWords: mockedWords,
                availableWords: mockedWords
            ),
            reducer: VerifyRecoveryPhraseModule.reducer,
            environment: VerifyRecoveryPhraseEnvironment(
                mainQueue: mainScheduler.eraseToAnyScheduler(),
                recoveryPhraseRepository: recpveryPhraseRepositoryMock,
                recoveryPhraseService: recoveryPhraseVerifyingServiceMock,
                onNext: {}
            )
        )

        testStore.send(.onVerifyTap)
        mainScheduler.advance()
        testStore.receive(.onPhraseVerifySuccess) {
            $0.backupPhraseStatus = .loading
        }
        XCTAssertTrue(recoveryPhraseVerifyingServiceMock.markBackupVerifiedCalled)
        XCTAssertTrue(recpveryPhraseRepositoryMock.updateMnemonicBackupCalled)

        mainScheduler.advance()
        testStore.receive(.onPhraseVerifyComplete) {
            $0.backupPhraseStatus = .success
        }
    }

    func test_onVerify_Tap_failed() {
        let mockedWords = MockGenerator.mockedWords
        testStore = TestStore(
            initialState: .init(
                selectedWords: mockedWords.shuffled(),
                availableWords: mockedWords
            ),
            reducer: VerifyRecoveryPhraseModule.reducer,
            environment: VerifyRecoveryPhraseEnvironment(
                mainQueue: mainScheduler.eraseToAnyScheduler(),
                recoveryPhraseRepository: recpveryPhraseRepositoryMock,
                recoveryPhraseService: recoveryPhraseVerifyingServiceMock,
                onNext: {}
            )
        )

        testStore.send(.onVerifyTap)
        mainScheduler.advance()
        testStore.receive(.onPhraseVerifyFailed) {
            $0.backupPhraseStatus = .failed
        }
    }

    func test_onPhraseVerifyBackup_Failed() {
        testStore.send(.onPhraseVerifyBackupFailed) {
            $0.backupPhraseStatus = .readyToVerify
            $0.backupRemoteFailed = true
        }
    }

    func test_onResetWords_Tap() {
        let mockedWords = MockGenerator.mockedWords
        testStore = TestStore(
            initialState: .init(
                selectedWords: mockedWords
            ),
            reducer: VerifyRecoveryPhraseModule.reducer,
            environment: VerifyRecoveryPhraseEnvironment(
                mainQueue: mainScheduler.eraseToAnyScheduler(),
                recoveryPhraseRepository: recpveryPhraseRepositoryMock,
                recoveryPhraseService: recoveryPhraseVerifyingServiceMock,
                onNext: {}
            )
        )

        testStore.send(.onResetWordsTap) {
            $0.backupPhraseStatus = .idle
            $0.selectedWords = []
        }
    }
 }
