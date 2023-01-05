// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SafariServices
import SwiftUI

public struct SafariView: UIViewControllerRepresentable {

    let url: URL

    public init(destination: String) {
        self.url = URL(string: destination)!
    }

    public func makeUIViewController(
        context: UIViewControllerRepresentableContext<SafariView>
    ) -> SFSafariViewController {
        SFSafariViewController(url: url)
    }

    public func updateUIViewController(
        _ uiViewController: SFSafariViewController,
        context: UIViewControllerRepresentableContext<SafariView>
    ) {}
}
