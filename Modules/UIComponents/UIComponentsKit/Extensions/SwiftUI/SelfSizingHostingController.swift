// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

public class SelfSizingHostingController<Content>: UIHostingController<Content> where Content: View {
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.invalidateIntrinsicContentSize()
    }
}
