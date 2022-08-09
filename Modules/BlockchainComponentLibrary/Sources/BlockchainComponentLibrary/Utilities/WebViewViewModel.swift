// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import WebKit

/// A class that allows you to observe `WKWebView` properties.
/// [Link to Source](https://github.com/phatblat/WebView/blob/main/Sources/WebView/WebViewStore.swift)
@dynamicMemberLookup
public class WebViewViewModel: ObservableObject {
    private var observers = Set<NSKeyValueObservation>()

    @Published public var webView: WKWebView {
        didSet {
            setupObservers()
        }
    }

    /// Initializes a new WebView.
    /// - Parameter webView: Optional custom webview.
    /// Default WKWebView will be constructed if not provided.
    public init(webView: WKWebView) {
        self.webView = webView
        setupObservers()
    }

    /// Enables KeyPath access to wrapped WKWebView properties.
    public subscript<T>(dynamicMember keyPath: KeyPath<WKWebView, T>) -> T {
        webView[keyPath: keyPath]
    }
}

extension WebViewViewModel {
    private func setupObservers() {
        func subscriber<Value>(for keyPath: KeyPath<WKWebView, Value>) -> NSKeyValueObservation {
            webView.observe(keyPath, options: [.prior]) { _, change in
                if change.isPrior {
                    self.objectWillChange.send()
                }
            }
        }

        observers = [
            subscriber(for: \.title),
            subscriber(for: \.url),
            subscriber(for: \.isLoading),
            subscriber(for: \.estimatedProgress),
            subscriber(for: \.hasOnlySecureContent),
            subscriber(for: \.serverTrust),
            subscriber(for: \.canGoBack),
            subscriber(for: \.canGoForward)
        ]
    }
}
