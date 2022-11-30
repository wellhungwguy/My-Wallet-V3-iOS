// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Combine
import DIKit
import EthereumKit
import FeatureWalletConnectDomain
import Foundation
import MoneyKit
import PlatformKit
import ToolKit
import WalletConnectSwift

final class WalletConnectService {

    // MARK: - Private Properties

    private var server: Server!
    private var cancellables = [AnyCancellable]()
    private var sessionLinks = Atomic<[WCURL: Session]>([:])

    private let sessionEventsSubject = PassthroughSubject<WalletConnectSessionEvent, Never>()
    private let userEventsSubject = PassthroughSubject<WalletConnectUserEvent, Never>()

    private let analyticsEventRecorder: AnalyticsEventRecorderAPI
    private let sessionRepository: SessionRepositoryAPI
    private let publicKeyProvider: WalletConnectPublicKeyProviderAPI
    private let enabledCurrenciesService: EnabledCurrenciesServiceAPI

    private let featureFlagService: FeatureFlagsServiceAPI

    // MARK: - Init

    init(
        analyticsEventRecorder: AnalyticsEventRecorderAPI = resolve(),
        publicKeyProvider: WalletConnectPublicKeyProviderAPI = resolve(),
        sessionRepository: SessionRepositoryAPI = resolve(),
        featureFlagService: FeatureFlagsServiceAPI = resolve(),
        enabledCurrenciesService: EnabledCurrenciesServiceAPI = resolve()
    ) {
        self.analyticsEventRecorder = analyticsEventRecorder
        self.publicKeyProvider = publicKeyProvider
        self.sessionRepository = sessionRepository
        self.featureFlagService = featureFlagService
        self.enabledCurrenciesService = enabledCurrenciesService
        server = Server(delegate: self)
        configureServer()
    }

    // MARK: - Private Methods

    private func configureServer() {
        let sessionEvent: (WalletConnectSessionEvent) -> Void = { [sessionEventsSubject] sessionEvent in
            sessionEventsSubject.send(sessionEvent)
        }
        let userEvent: (WalletConnectUserEvent) -> Void = { [userEventsSubject] userEvent in
            userEventsSubject.send(userEvent)
        }
        let responseEvent: (WalletConnectResponseEvent) -> Void = { [weak server] responseEvent in
            switch responseEvent {
            case .empty(let request):
                server?.send(.create(string: nil, for: request))
            case .rejected(let request):
                server?.send(.reject(request))
            case .invalid(let request):
                server?.send(.invalid(request))
            case .signature(let signature, let request):
                server?.send(.create(string: signature, for: request))
            case .transactionHash(let transactionHash, let request):
                server?.send(.create(string: transactionHash, for: request))
            }
        }
        let getSession: (WCURL) -> Session? = { [sessionLinks] url in
            sessionLinks.value[url]
        }

        // personal_sign, eth_sign, eth_signTypedData
        server.register(
            handler: SignRequestHandler(
                getSession: getSession,
                getNetwork: { [enabledCurrenciesService] chainID in
                    network(enabledCurrenciesService: enabledCurrenciesService, chainID: chainID)
                },
                responseEvent: responseEvent,
                userEvent: userEvent
            )
        )

        // eth_sendTransaction, eth_signTransaction
        server.register(
            handler: TransactionRequestHandler(
                getSession: getSession,
                getNetwork: { [enabledCurrenciesService] chainID in
                    network(enabledCurrenciesService: enabledCurrenciesService, chainID: chainID)
                },
                responseEvent: responseEvent,
                userEvent: userEvent
            )
        )

        // eth_sendRawTransaction
        server.register(
            handler: RawTransactionRequestHandler(
                getSession: getSession,
                getNetwork: { [enabledCurrenciesService] chainID in
                    network(enabledCurrenciesService: enabledCurrenciesService, chainID: chainID)
                },
                responseEvent: responseEvent,
                userEvent: userEvent
            )
        )

        // wallet_switchEthereumChain
        server.register(
            handler: SwitchRequestHandler(
                getSession: getSession,
                getNetwork: { [enabledCurrenciesService] chainID in
                    network(enabledCurrenciesService: enabledCurrenciesService, chainID: chainID)
                },
                responseEvent: responseEvent,
                sessionEvent: sessionEvent
            )
        )

        publicKeyProvider
            .publicKey(network: .ethereum)
            .ignoreFailure(setFailureType: Never.self)
            .zip(sessionRepository.retrieve())
            .map { publicKey, sessions -> [Session] in
                sessions
                    .compactMap { session in
                        session.session(address: publicKey)
                    }
            }
            .handleEvents(
                receiveOutput: { [server, sessionLinks] sessions in
                    sessions
                        .forEach { session in
                            sessionLinks.mutate {
                                $0[session.url] = session
                            }
                            try? server?.reconnect(to: session)
                        }
                }
            )
            .subscribe()
            .store(in: &cancellables)
    }

    private func addOrUpdateSession(session: Session) {
        sessionLinks.mutate {
            $0[session.url] = session
        }
    }
}

extension WalletConnectService: ServerDelegateV2 {

    // MARK: - ServerDelegate

    func server(_ server: Server, didFailToConnect url: WCURL) {
        guard let session = sessionLinks.value[url] else {
            return
        }
        sessionEventsSubject.send(.didFailToConnect(session))
    }

    func server(_ server: Server, shouldStart session: Session, completion: @escaping (Session.WalletInfo) -> Void) {
        // Method not called on `ServerDelegateV2`.
    }

    func server(_ server: Server, didReceiveConnectionRequest requestId: RequestID, for session: Session) {
        addOrUpdateSession(session: session)
        let completion: (Session.WalletInfo) -> Void = { [server] walletInfo in
            server.sendCreateSessionResponse(
                for: requestId,
                session: session,
                walletInfo: walletInfo
            )
        }
        sessionEventsSubject.send(.shouldStart(session, completion))
    }

    func server(_ server: Server, willReconnect session: Session) {
        // NOOP
    }

    func server(_ server: Server, didConnect session: Session) {
        addOrUpdateSession(session: session)
        sessionRepository
            .contains(session: session)
            .flatMap { [sessionRepository] containsSession in
                sessionRepository
                    .store(session: session)
                    .map { containsSession }
            }
            .sink { [sessionEventsSubject] containsSession in
                if !containsSession {
                    sessionEventsSubject.send(.didConnect(session))
                }
            }
            .store(in: &cancellables)
    }

    func server(_ server: Server, didDisconnect session: Session) {
        sessionRepository
            .remove(session: session)
            .sink { [sessionEventsSubject] _ in
                sessionEventsSubject.send(.didDisconnect(session))
            }
            .store(in: &cancellables)
    }

    func server(_ server: Server, didUpdate session: Session) {
        addOrUpdateSession(session: session)
        sessionRepository
            .store(session: session)
            .sink { [sessionEventsSubject] _ in
                sessionEventsSubject.send(.didUpdate(session))
            }
            .store(in: &cancellables)
    }
}

extension WalletConnectService: WalletConnectServiceAPI {

    // MARK: - WalletConnectServiceAPI

    var userEvents: AnyPublisher<WalletConnectUserEvent, Never> {
        userEventsSubject.eraseToAnyPublisher()
    }

    var sessionEvents: AnyPublisher<WalletConnectSessionEvent, Never> {
        sessionEventsSubject.eraseToAnyPublisher()
    }

    func acceptConnection(
        session: Session,
        completion: @escaping (Session.WalletInfo) -> Void
    ) {
        guard let network = network(enabledCurrenciesService: enabledCurrenciesService, chainID: session.dAppInfo.chainId ?? 1) else {
            if BuildFlag.isInternal {
                let chainID = session.dAppInfo.chainId
                let meta = session.dAppInfo.peerMeta
                fatalError("Unsupported ChainID: '\(chainID ?? 0)' ,'\(meta.name)', '\(meta.url.absoluteString)'")
            }
            return
        }

        publicKeyProvider
            .publicKey(network: network)
            .map { publicKey in
                Session.WalletInfo(
                    approved: true,
                    accounts: [publicKey],
                    chainId: Int(network.networkConfig.chainID),
                    peerId: UUID().uuidString,
                    peerMeta: .blockchain
                )
            }
            .sink { [completion] walletInfo in
                completion(walletInfo)
            }
            .store(in: &cancellables)
    }

    func denyConnection(
        session: Session,
        completion: @escaping (Session.WalletInfo) -> Void
    ) {
        let walletInfo = Session.WalletInfo(
            approved: false,
            accounts: [],
            chainId: session.dAppInfo.chainId ?? 1,
            peerId: UUID().uuidString,
            peerMeta: .blockchain
        )
        completion(walletInfo)
    }

    func connect(_ url: String) {
        featureFlagService.isEnabled(.walletConnectEnabled)
            .sink { [weak self] isEnabled in
                guard isEnabled,
                      let wcUrl = WCURL(url)
                else {
                    return
                }
                try? self?.server.connect(to: wcUrl)
            }
            .store(in: &cancellables)
    }

    func disconnect(_ session: Session) {
        try? server.disconnect(from: session)
    }

    func respondToChainIDChangeRequest(
        session: Session,
        request: Request,
        network: EVMNetwork,
        approved: Bool
    ) {
        guard approved else {
            server?.send(.reject(request))
            return
        }

        // Create new session information.
        guard let oldWalletInfo = sessionLinks.value[session.url]?.walletInfo else {
            server?.send(.reject(request))
            return
        }
        let walletInfo = Session.WalletInfo(
            approved: oldWalletInfo.approved,
            accounts: oldWalletInfo.accounts,
            chainId: Int(network.networkConfig.chainID),
            peerId: oldWalletInfo.peerId,
            peerMeta: oldWalletInfo.peerMeta
        )
        let newSession = Session(
            url: session.url,
            dAppInfo: session.dAppInfo,
            walletInfo: walletInfo
        )

        // Update local cache.
        addOrUpdateSession(session: newSession)

        // Update session repository.
        sessionRepository
            .store(session: newSession)
            .subscribe()
            .store(in: &cancellables)

        // Request session update.
        try? server.updateSession(session, with: walletInfo)

        // Respond accepting change.
        server?.send(.create(string: nil, for: request))
    }
}

extension Response {

    /// Response for any 'sign'/'send' method that sends back a single string as result.
    fileprivate static func create(string: String?, for request: Request) -> Response {
        guard let response = try? Response(url: request.url, value: string, id: request.id!) else {
            fatalError("Wallet Connect Response Failed: \(request.method)")
        }
        return response
    }
}

private func network(enabledCurrenciesService: EnabledCurrenciesServiceAPI, chainID: Int) -> EVMNetwork? {
    enabledCurrenciesService
        .allEnabledEVMNetworks
        .first(where: { network in
            network.networkConfig.chainID == chainID
        })
}
