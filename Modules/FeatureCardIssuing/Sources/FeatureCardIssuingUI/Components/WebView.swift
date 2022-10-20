// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {

    enum CallbackUrl {
        static let activate = "https://blockchain.com/en/app/card-issuing/activated"
        static let pin = "https://blockchain.com/en/app/card-issuing/pinset"
    }

    @Binding var loading: Bool

    private let url: URL
    let finishUrl: String?
    let forceFullScreen: Bool
    let onFinish: (() -> Void)?

    init(
        url: URL,
        loading: Binding<Bool>? = nil,
        finishUrl: String? = nil,
        forceFullScreen: Bool = false,
        onFinish: (() -> Void)? = nil
    ) {
        self.url = url
        self.finishUrl = finishUrl
        self.forceFullScreen = forceFullScreen
        self.onFinish = onFinish
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

        return webView
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        context.coordinator.updateUIView(uiView, for: self)
    }

    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {}

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
                  loadingUrl.absoluteString.contains(finishUrl),
                  let onFinish = parent.onFinish else {
                decisionHandler(.allow)
                return
            }

            onFinish()
        }
    }
}
