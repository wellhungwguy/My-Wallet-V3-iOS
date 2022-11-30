// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {

    enum CallbackUrl {
        static let activate = "https://blockchain.com/app/card-issuing/activated"
        static let pin = "https://blockchain.com/app/card-issuing/pinset"
    }

    static let listenerName = "actions"
    struct Event: Decodable {

        enum EventType: String, Decodable {
            case view = "VIEW"
            case manage = "MANAGE"
        }

        let type: EventType
    }

    @Binding var loading: Bool

    private let url: URL
    let finishUrl: String?
    let forceFullScreen: Bool
    let callback: ((Event) -> Void)?
    let onFinish: (() -> Void)?

    init(
        url: URL,
        loading: Binding<Bool>? = nil,
        finishUrl: String? = nil,
        forceFullScreen: Bool = false,
        callback: ((Event) -> Void)? = nil,
        onFinish: (() -> Void)? = nil
    ) {
        self.url = url
        self.finishUrl = finishUrl
        self.forceFullScreen = forceFullScreen
        self.onFinish = onFinish
        self.callback = callback
        _loading = loading ?? .constant(false)
    }

    func makeUIView(context: Context) -> WKWebView {
        let webView: WKWebView
        if forceFullScreen {
            // swiftlint:disable line_length
            let script = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);"
            let userScript = WKUserScript(source: script, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
            let userContentController = WKUserContentController()
            userContentController.addUserScript(userScript)
            let config = WKWebViewConfiguration()
            config.userContentController = userContentController
            webView = WKWebView(frame: .zero, configuration: config)
        } else {
            webView = WKWebView()
        }
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        webView.navigationDelegate = context.coordinator
        webView.configuration.userContentController.add(context.coordinator, name: WebView.listenerName)

        return webView
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        context.coordinator.updateUIView(uiView, for: self)
    }

    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {

        enum State {
            case loading(URL)
            case loaded(URL)
            case error
            case idle
        }

        private var state: State = .idle
        private var parent: WebView

        init(_ parent: WebView) {
            self.parent = parent
        }

        func updateUIView(_ uiView: WKWebView, for parent: WebView) {

            func load() {
                uiView.stopLoading()
                state = .loading(parent.url)
                uiView.load(URLRequest(url: parent.url))
            }

            self.parent = parent

            switch state {
            case .loading(let url) where url != parent.url,
                .loaded(let url) where url != parent.url:
                load()
            case .error, .idle:
                load()
            default:
                break
            }
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            guard case .loading(let url) = state, url == parent.url else {
                return
            }

            state = .loaded(parent.url)

            DispatchQueue.main.async { [weak self] in
                self?.parent.loading = false
            }
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            state = .error

            DispatchQueue.main.async { [weak self] in
                self?.parent.loading = false
            }
        }

        func webView(
            _ webView: WKWebView,
            decidePolicyFor navigationAction: WKNavigationAction,
            decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
        ) {
            guard let finishUrl = parent.finishUrl,
                  let loadingUrl = navigationAction.request.url,
                  loadingUrl.absoluteString == finishUrl,
                  let onFinish = parent.onFinish
            else {
                decisionHandler(.allow)
                return
            }

            decisionHandler(.cancel)
            onFinish()
        }

        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            guard let event = message.body as? [String: AnyObject],
                  let data = try? JSONSerialization.data(withJSONObject: event),
                  let event = try? JSONDecoder().decode(WebView.Event.self, from: data)
            else {
                return
            }

            parent.callback?(event)
        }
    }
}
