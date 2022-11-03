// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import MetadataHDWalletKit

extension CharacterSet {

    fileprivate static var integers: CharacterSet {
        CharacterSet(charactersIn: "0123456789")
    }
}

public enum DerivationComponent {
    case hardened(UInt32)
    case normal(UInt32)

    public var description: String {
        switch self {
        case .normal(let index):
            return "\(index)"
        case .hardened(let index):
            return "\(index)'"
        }
    }

    public var isHardened: Bool {
        switch self {
        case .normal:
            return false
        case .hardened:
            return true
        }
    }

    var derivationNode: DerivationNode {
        switch self {
        case .normal(let value):
            return .notHardened(value)
        case .hardened(let value):
            return .hardened(value)
        }
    }

    init?(item: String) {
        let hardened = item.hasSuffix("'")
        let indexString = item.trimmingCharacters(in: CharacterSet.integers.inverted)
        guard let index = UInt32(indexString) else {
            return nil
        }
        guard hardened else {
            self = .normal(index)
            return
        }
        self = .hardened(index)
    }

    func from(_ component: MetadataHDWalletKit.DerivationNode) -> Self {
        switch component {
        case .hardened(let index):
            return .hardened(index)
        case .notHardened(let index):
            return .normal(index)
        }
    }
}

extension [DerivationComponent] {

    public func with(normal index: UInt32) -> Self {
        self + [.normal(index)]
    }

    public func with(hardened index: UInt32) -> Self {
        self + [.hardened(index)]
    }

    public var path: String {
        "m/" + map(\.description).joined(separator: "/")
    }
}
