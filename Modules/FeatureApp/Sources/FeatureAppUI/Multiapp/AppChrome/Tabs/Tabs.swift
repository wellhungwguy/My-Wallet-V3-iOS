// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import ErrorsUI
import Foundation

// Copied over from `RootView`

struct Tab: Hashable, Identifiable, Codable {
    var id: AnyHashable { tag }
    var tag: Tag.Reference
    var name: String
    var ux: UX.Dialog?
    var url: URL?
    var icon: Icon
    var unselectedIcon: Icon?
}

extension Tab: CustomStringConvertible {
    var description: String { tag.string }
}

extension Tab {

    var ref: Tag.Reference { tag }

    // swiftlint:disable force_try

    // OA Add support for pathing directly into a reference
    // e.g. ref.descendant(blockchain.ux.type.story, \.entry)
    func entry() -> Tag.Reference {
        try! ref.tag.as(blockchain.ux.type.story).entry[].ref(to: ref.context)
    }
}
