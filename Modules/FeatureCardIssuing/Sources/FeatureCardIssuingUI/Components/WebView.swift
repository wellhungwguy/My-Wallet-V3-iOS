// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {

    @Binding var loading: Bool

    private let url: URL

    init(
        url: URL,
        loading: Binding<Bool>
    ) {
        self.url = url
        _loading = loading
    }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
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

    class Coordinator: NSObject, WKNavigationDelegate {

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
    }
}
