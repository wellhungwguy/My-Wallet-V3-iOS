// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import BlockchainNamespace
import Combine
import DIKit
import Errors
@testable import FeatureUserTagSyncDomain
import XCTest

final class FeatureUserTagSyncDomainTests: XCTestCase {
    var app: AppProtocol!
    var mockUserTagService: MockUserTagService!
    var sut: UserTagObserver! {
        didSet { sut?.start() }
    }

    private var cancellable = Set<AnyCancellable>()

    override func setUp() {
        super.setUp()
        app = App.test
        mockUserTagService = MockUserTagService()
        sut = UserTagObserver(app: app, userTagSyncService: mockUserTagService)
        app.remoteConfiguration.override(blockchain.api.nabu.gateway.user.tag.service.is.enabled, with: true)
    }

    override func tearDown() {
        mockUserTagService = nil
        super.tearDown()
    }

    func testSyncWhenUserHasNoTagsAndFlagIsTrue() throws {
        // GIVEN
        let remoteSuperAppFlagValue = false
        app.remoteConfiguration.override(blockchain.app.configuration.app.superapp.is.enabled, with: remoteSuperAppFlagValue)
        app.state.set(blockchain.user.is.superapp.user, to: nil)

        // WHEN
        app.post(event: blockchain.user.event.did.update)
        let methodCallExpectation = expectation(description: "Update super app tag called")

        var updatedTagValue: Bool?
        mockUserTagService.updateSuperAppTagCalledWith
            .sink { updatedValue in
                updatedTagValue = updatedValue
                methodCallExpectation.fulfill()
            }
            .store(in: &cancellable)

        wait(for: [methodCallExpectation], timeout: 1)

        // THEN
        XCTAssertEqual(updatedTagValue, remoteSuperAppFlagValue)
    }

    func testSyncWhenUserHasTagButTheFlagIsDifferent() throws {
        // GIVEN
        let remoteSuperAppFlagValue = false
        app.remoteConfiguration.override(blockchain.app.configuration.app.superapp.is.enabled, with: remoteSuperAppFlagValue)
        app.state.set(blockchain.user.is.superapp.user, to: true)

        // WHEN
        app.post(event: blockchain.user.event.did.update)
        let methodCallExpectation = expectation(description: "Update super app tag called")

        var updatedTagValue: Bool?
        mockUserTagService.updateSuperAppTagCalledWith
            .sink { updatedValue in
                updatedTagValue = updatedValue
                methodCallExpectation.fulfill()
            }
            .store(in: &cancellable)

        wait(for: [methodCallExpectation], timeout: 1)

        // THEN
        XCTAssertEqual(updatedTagValue, remoteSuperAppFlagValue)
    }

    func testSyncNotCalledWhenFlagsAreTheSame() throws {
        // GIVEN
        let remoteSuperAppFlagValue = true
        app.remoteConfiguration.override(blockchain.app.configuration.app.superapp.is.enabled, with: remoteSuperAppFlagValue)
        app.state.set(blockchain.user.is.superapp.user, to: remoteSuperAppFlagValue)

        // WHEN
        app.post(event: blockchain.user.event.did.update)

        // THEN
        XCTAssertFalse(mockUserTagService.updateSuperAppTagMethodCalled)
    }
}

class MockUserTagService: UserTagServiceAPI {
    var updateSuperAppTagCalledWith = PassthroughSubject<Bool?, Never>()
    var updateSuperAppTagMethodCalled = false

    func updateSuperAppTag(isEnabled: Bool) -> AnyPublisher<Void, Errors.NetworkError> {
        updateSuperAppTagMethodCalled = true
        updateSuperAppTagCalledWith.send(isEnabled)
        return .just(())
    }
}
