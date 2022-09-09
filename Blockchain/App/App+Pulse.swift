//  Copyright © 2022 Blockchain Luxembourg S.A. All rights reserved.

#if DEBUG || ALPHA_BUILD || INTERNAL_BUILD
import PulseCore
import PulseUI
#endif

import BlockchainNamespace
import Combine
import FeatureDebugUI
import NetworkKit
import SwiftUI

#if DEBUG || ALPHA_BUILD || INTERNAL_BUILD
final class PulseBlockchainNamespaceEventLogger: Session.Observer {

    typealias Logger = PulseCore.LoggerStore

    unowned var app: AppProtocol

    var pulse: Logger = .default

    private var subscription: BlockchainEventSubscription? {
        didSet { subscription?.start() }
    }

    init(app: AppProtocol) {
        self.app = app
    }

    func start() {
        subscription = app.on(blockchain.ux.type.analytics.event) { @MainActor [pulse] event in
            pulse.storeMessage(
                label: "namespace",
                level: .info,
                message: event.description,
                metadata: event.context.mapKeysAndValues(
                    key: \.description,
                    value: String.init(describing:)
                )
                .mapValues(Logger.MetadataValue.string),
                file: event.reference.context[
                    blockchain.ux.type.analytics.event.source.file
                ] as? String ?? event.source.file,
                function: "App.post(event:context:)",
                line: UInt(event.reference.context[
                    blockchain.ux.type.analytics.event.source.line
                ] as? Int ?? event.source.line)
            )
        }
    }

    func stop() {
        subscription = nil
    }
}
#endif

final class PulseNetworkDebugLogger: NetworkDebugLogger {

    // swiftlint:disable function_parameter_count
    func storeRequest(
        _ request: URLRequest,
        response: URLResponse?,
        error: Error?,
        data: Data?,
        metrics: URLSessionTaskMetrics?,
        session: URLSession?
    ) {
        #if DEBUG || ALPHA_BUILD || INTERNAL_BUILD
        LoggerStore.default.storeRequest(
            request,
            response: response,
            error: error,
            data: data,
            metrics: metrics,
            session: session
        )
        #endif
    }
}

final class PulseNetworkDebugScreenProvider: NetworkDebugScreenProvider {
    @ViewBuilder func buildDebugView() -> AnyView {
    #if DEBUG || ALPHA_BUILD || INTERNAL_BUILD
         AnyView(MainView())
    #else
        AnyView(EmptyView())
    #endif
    }
}
