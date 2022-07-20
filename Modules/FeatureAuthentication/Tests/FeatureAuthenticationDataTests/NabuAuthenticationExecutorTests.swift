// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
@testable import FeatureAuthenticationData
@testable import FeatureAuthenticationDomain
@testable import FeatureAuthenticationMock
@testable import NetworkKit
@testable import ToolKitMock
import XCTest

// swiftlint:disable type_body_length
final class NabuAuthenticationExecutorTests: XCTestCase {

    private var cancellables: Set<AnyCancellable>!
    private var store: NabuTokenRepositoryAPI!
    private var errorBroadcaster: MockUserAlreadyRestoredHandler!
    private var walletRepository: MockWalletRepository!
    private var nabuOfflineTokenRepo: MockNabuOfflineTokenRepository!
    private var nabuRepository: MockNabuRepository!
    private var nabuUserEmailProvider: NabuUserEmailProvider = { .just("abcd@abcd.com") }
    private var deviceInfo: MockDeviceInfo!
    private var jwtService: JWTServiceMock!
    private var siftService: MockSiftService!
    private var checkAuthenticated: CheckAuthenticated = { _ in .just(true) }
    private var subject: NabuAuthenticationExecutorAPI!

    override func setUpWithError() throws {
        try super.setUpWithError()

        cancellables = Set<AnyCancellable>([])
        store = NabuTokenRepository()
        errorBroadcaster = MockUserAlreadyRestoredHandler()
        nabuRepository = MockNabuRepository()
        walletRepository = MockWalletRepository()
        nabuOfflineTokenRepo = MockNabuOfflineTokenRepository()
        deviceInfo = MockDeviceInfo(
            systemVersion: "1.2.3",
            model: "iPhone5S",
            uuidString: "uuid"
        )
        jwtService = JWTServiceMock()
        siftService = MockSiftService()
        subject = NabuAuthenticationExecutor(
            app: App.test,
            store: store,
            errorBroadcaster: errorBroadcaster,
            nabuRepository: nabuRepository,
            nabuUserEmailProvider: nabuUserEmailProvider,
            siftService: siftService,
            checkAuthenticated: checkAuthenticated,
            jwtService: jwtService,
            credentialsRepository: walletRepository,
            nabuOfflineTokenRepository: nabuOfflineTokenRepo,
            deviceInfo: deviceInfo
        )
    }

    override func tearDownWithError() throws {
        cancellables = nil
        nabuRepository = nil
        errorBroadcaster = nil
        store = nil
        siftService = nil
        jwtService = nil
        walletRepository = nil
        deviceInfo = nil
        subject = nil

        try super.tearDownWithError()
    }

    // swiftlint:disable function_body_length
    func testSuccessfulAuthenticationWhenUserIsAlreadyCreated() throws {

        // Arrange
        let expectedSessionTokenValue = "session-token"

        let offlineToken = NabuOfflineToken(
            userId: "user-id",
            token: "offline-token"
        )

        jwtService.expectedResult = .success("jwt-token")

        let offlineTokenResponseSetExpectation = expectation(
            description: "The offline token was set successfully"
        )
        walletRepository
            .set(
                offlineToken: offlineToken
            )
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    offlineTokenResponseSetExpectation.fulfill()
                case .failure(let error):
                    XCTFail("Failed to set the offlineToken error: \(error)")
                }
            }, receiveValue: { _ in })
            .store(in: &cancellables)

        nabuRepository.expectedOfflineToken = .success(offlineToken)
        nabuRepository.expectedSessionToken = .success(
            NabuSessionToken(
                identifier: "identifier",
                userId: "user-id",
                token: expectedSessionTokenValue,
                isActive: true,
                expiresAt: .distantFuture
            )
        )

        let guidSetExpectation = expectation(
            description: "The GUID was set successfully"
        )
        walletRepository
            .set(
                guid: "guid"
            )
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    guidSetExpectation.fulfill()
                case .failure(let error):
                    XCTFail("Failed to set the guid error: \(error)")
                }
            }, receiveValue: { _ in })
            .store(in: &cancellables)

        let sharedKeySetExpectation = expectation(
            description: "The Shared Key was set successfully"
        )
        walletRepository
            .set(
                sharedKey: "shared-key"
            )
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    sharedKeySetExpectation.fulfill()
                case .failure(let error):
                    XCTFail("Failed to set the sharedKey error: \(error)")
                }
            }, receiveValue: { _ in })
            .store(in: &cancellables)

        wait(
            for: [
                offlineTokenResponseSetExpectation,
                guidSetExpectation,
                sharedKeySetExpectation
            ],
            timeout: 20,
            enforceOrder: false
        )

        let receivedValidTokenExpectation = expectation(
            description: "Received Valid token"
        )
        let authenticationSuccessfulExpectation = expectation(
            description: "The user was created and sucessfully authenticated"
        )

        // Act
        subject
            .authenticate { token -> AnyPublisher<ServerResponse, NetworkError> in
                AnyPublisher.just(
                    ServerResponse(
                        payload: token.data(using: .utf8),
                        response: HTTPURLResponse(
                            url: URL(string: "https://blockchain.com/")!,
                            statusCode: 200,
                            httpVersion: nil,
                            headerFields: nil
                        )!
                    )
                )
            }
            .map { response -> String in
                String(data: response.payload!, encoding: .utf8)!
            }
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    authenticationSuccessfulExpectation.fulfill()
                case .failure(let error):
                    XCTFail("Authentication failed with error: \(String(describing: error))")
                }
            }, receiveValue: { value in
                XCTAssertEqual(value, expectedSessionTokenValue)
                receivedValidTokenExpectation.fulfill()
            })
            .store(in: &cancellables)

        // Assert
        wait(
            for: [
                receivedValidTokenExpectation,
                authenticationSuccessfulExpectation
            ],
            timeout: 20,
            enforceOrder: false
        )
    }

    // swiftlint:disable function_body_length
    func testSuccessfulAuthenticationWhenUserIsNotCreated() throws {

        // Arrange
        let expectedSessionTokenValue = "session-token"

        let offlineToken = NabuOfflineToken(userId: "user-id", token: "offline-token")

        // Offline token is missing - user creation will be attempted
        nabuOfflineTokenRepo.expectedOfflineToken = .failure(.offlineToken)
        jwtService.expectedResult = .success("jwt-token")
        nabuRepository.expectedOfflineToken = .success(offlineToken)

        nabuRepository.expectedSessionToken = .success(
            NabuSessionToken(
                identifier: "identifier",
                userId: "user-id",
                token: expectedSessionTokenValue,
                isActive: true,
                expiresAt: .distantFuture
            )
        )

        let guidSetExpectation = expectation(
            description: "The GUID was set successfully"
        )
        walletRepository
            .set(
                guid: "guid"
            )
            .sink(receiveCompletion: { completion in
                guard case .finished = completion else {
                    XCTFail("failed to set the guid")
                    return
                }
                guidSetExpectation.fulfill()
            }, receiveValue: { _ in })
            .store(in: &cancellables)

        let sharedKeySetExpectation = expectation(
            description: "The Shared Key was set successfully"
        )
        walletRepository
            .set(
                sharedKey: "shared-key"
            )
            .sink(receiveCompletion: { completion in
                guard case .finished = completion else {
                    XCTFail("failed to set the shared key")
                    return
                }
                sharedKeySetExpectation.fulfill()
            }, receiveValue: { _ in })
            .store(in: &cancellables)

        wait(for: [guidSetExpectation, sharedKeySetExpectation], timeout: 5, enforceOrder: false)

        let receivedValidTokenExpectation = expectation(
            description: "Received Valid token"
        )
        let authenticationSuccessfulExpectation = expectation(
            description: "The user was created and sucessfully authenticated"
        )

        // Act
        subject
            .authenticate { token -> AnyPublisher<ServerResponse, NetworkError> in
                AnyPublisher.just(
                    ServerResponse(
                        payload: token.data(using: .utf8),
                        response: HTTPURLResponse(
                            url: URL(string: "https://blockchain.com/")!,
                            statusCode: 200,
                            httpVersion: nil,
                            headerFields: nil
                        )!
                    )
                )
            }
            .map { response -> String in
                String(data: response.payload!, encoding: .utf8)!
            }
            .sink(receiveCompletion: { [unowned self] completion in
                switch completion {
                case .finished:
                    XCTAssertEqual(
                        // swiftlint:disable:next force_try
                        try! self.nabuOfflineTokenRepo.expectedOfflineToken.get(),
                        offlineToken
                    )
                    authenticationSuccessfulExpectation.fulfill()
                case .failure(let error):
                    XCTFail("Failed with error: \(String(describing: error))")
                }
            }, receiveValue: { value in
                XCTAssertEqual(value, expectedSessionTokenValue)
                receivedValidTokenExpectation.fulfill()
            })
            .store(in: &cancellables)

        // Assert
        wait(
            for: [receivedValidTokenExpectation, authenticationSuccessfulExpectation],
            timeout: 20,
            enforceOrder: true
        )
    }

    // swiftlint:disable function_body_length
    func testExpiredTokenAndSecondSuccessfulAuthentication() throws {

        // Arrange
        let offlineToken = NabuOfflineToken(
            userId: "user-id",
            token: "offline-token"
        )

        let expiredSessionToken = NabuSessionToken(
            identifier: "identifier",
            userId: "user-id",
            token: "expired-session-token",
            isActive: true,
            expiresAt: Date.distantPast
        )

        let newSessionToken = NabuSessionToken(
            identifier: "identifier",
            userId: "user-id",
            token: "new-session-token",
            isActive: true,
            expiresAt: Date.distantFuture
        )

        let expiredAuthTokenStoredExpectation = expectation(
            description: "The expired auth token was successfully stored"
        )
        // Store expired session token
        store
            .store(expiredSessionToken)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        expiredAuthTokenStoredExpectation.fulfill()
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)

        jwtService.expectedResult = .success("jwt-token")

        nabuRepository.expectedOfflineToken = .success(offlineToken)
        nabuRepository.expectedSessionToken = .success(newSessionToken)

        wait(for: [expiredAuthTokenStoredExpectation], timeout: 5, enforceOrder: true)

        let offlineTokenResponseSetExpectation = expectation(
            description: "The offline token was set successfully"
        )
        walletRepository
            .set(
                offlineToken: offlineToken
            )
            .sink(receiveCompletion: { completion in
                guard case .finished = completion else {
                    XCTFail("failed to set the guid")
                    return
                }
                offlineTokenResponseSetExpectation.fulfill()
            }, receiveValue: { _ in })
            .store(in: &cancellables)

        let guidSetExpectation = expectation(
            description: "The GUID was set successfully"
        )
        walletRepository
            .set(
                guid: "guid"
            )
            .sink(receiveCompletion: { completion in
                guard case .finished = completion else {
                    XCTFail("failed to set the guid")
                    return
                }
                guidSetExpectation.fulfill()
            }, receiveValue: { _ in })
            .store(in: &cancellables)

        let sharedKeySetExpectation = expectation(
            description: "The Shared Key was set successfully"
        )
        walletRepository
            .set(
                sharedKey: "shared-key"
            )
            .sink(receiveCompletion: { completion in
                guard case .finished = completion else {
                    XCTFail("failed to set the shared key")
                    return
                }
                sharedKeySetExpectation.fulfill()
            }, receiveValue: { _ in })
            .store(in: &cancellables)

        wait(
            for: [
                offlineTokenResponseSetExpectation,
                guidSetExpectation,
                sharedKeySetExpectation
            ],
            timeout: 20,
            enforceOrder: true
        )

        // Act
        let receivedValidTokenExpectation = expectation(
            description: "Received Valid token"
        )
        let authenticationSuccessfulExpectation = expectation(
            description: "The user was created and sucessfully authenticated"
        )

        // Act
        subject
            .authenticate { token -> AnyPublisher<ServerResponse, NetworkError> in
                if token == newSessionToken.token {
                    return AnyPublisher.just(
                        ServerResponse(
                            payload: token.data(using: .utf8),
                            response: HTTPURLResponse(
                                url: URL(string: "https://blockchain.com/")!,
                                statusCode: 200,
                                httpVersion: nil,
                                headerFields: nil
                            )!
                        )
                    )
                } else {
                    let httpResponse = HTTPURLResponse(
                        url: URL(string: "https://www.blockchain.com")!,
                        statusCode: 401,
                        httpVersion: nil,
                        headerFields: nil
                    )!
                    let serverErrorResponse = ServerErrorResponse(
                        response: httpResponse,
                        payload: nil
                    )
                    return AnyPublisher.failure(
                        .unknown
                    )
                }
            }
            .map { response -> String in
                String(data: response.payload!, encoding: .utf8)!
            }
            .sink(receiveCompletion: { [unowned self] completion in
                switch completion {
                case .finished:
                    XCTAssertEqual(
                        // swiftlint:disable:next force_try
                        try! self.nabuOfflineTokenRepo.expectedOfflineToken.get(),
                        offlineToken
                    )
                    authenticationSuccessfulExpectation.fulfill()
                case .failure(let error):
                    XCTFail("Failed with error: \(String(describing: error))")
                }
            }, receiveValue: { value in
                XCTAssertEqual(value, newSessionToken.token)
                receivedValidTokenExpectation.fulfill()
            })
            .store(in: &cancellables)

        // Assert
        wait(
            for: [
                receivedValidTokenExpectation,
                authenticationSuccessfulExpectation
            ],
            timeout: 20,
            enforceOrder: true
        )
    }

    func testUserAlreadyRestoredShouldBroadcastError() {

        // Arrange (409 server error response)
        let offlineToken = NabuOfflineToken(
            userId: "user-id",
            token: "offline-token"
        )
        nabuOfflineTokenRepo.expectedOfflineToken = .success(offlineToken)
        walletRepository.expectedGuid = "guid"
        walletRepository.expectedSharedKey = "shared-key"
        jwtService.expectedResult = .success("jwt-token")

        let mockHttpResponse = HTTPURLResponse(
            url: URL(string: "https://www.blockchain.com")!,
            statusCode: 409,
            httpVersion: nil,
            headerFields: nil
        )!
        let mockPayload = """
            {
                "type": "CONFLICT",
                "description": "User linked to another wallet 3829...87c7"
            }
        """.data(using: .utf8)

        let mockNetworkError: NetworkError = NetworkError(
            request: URLRequest(url: "https://www.blockchain.com"),
            type: .rawServerError(
                .init(
                    response: mockHttpResponse,
                    payload: mockPayload
                )
            )
        )
        nabuRepository.expectedSessionToken = .failure(mockNetworkError)

        // Act (409 server error response)
        subject
            .authenticate { _ -> AnyPublisher<ServerResponse, NetworkError> in
                .failure(mockNetworkError)
            }
            .sink(
                receiveCompletion: { [unowned self] completion in
                    print(completion)
                    guard case .finished = completion else {
                        XCTFail("should broadcast error instead of return error")
                        return
                    }
                    XCTAssertEqual(errorBroadcaster.recordedWalletIdHint, "3829...87c7")
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
    }
}
