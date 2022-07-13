// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Parsing
import ToolKit

public enum HDKeyPathError: Error, Equatable {
    case invalidIndex
    case parsingError(Error)

    public static func == (lhs: HDKeyPathError, rhs: HDKeyPathError) -> Bool {
        switch (lhs, rhs) {
        case (.parsingError(let lhsError), .parsingError(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        case (.invalidIndex, .invalidIndex):
            return true
        default:
            return false
        }
    }
}

public enum DerivationComponent: Equatable {
    case normal(UInt32)
    case hardened(UInt32)

    var description: String {
        switch self {
        case .hardened(let index):
            return "\(index)'"
        case .normal(let index):
            return "\(index)"
        }
    }

    var isHardened: Bool {
        switch self {
        case .normal:
            return false
        case .hardened:
            return true
        }
    }

    static func normal(intValue: Int) -> Self {
        .normal(UInt32(intValue))
    }

    static func hardened(intValue: Int) -> Self {
        .hardened(UInt32(intValue))
    }
}

extension Array where Element == DerivationComponent {

    func with(normal index: UInt32) -> Self {
        self + [.normal(index)]
    }

    func with(hardened index: UInt32) -> Self {
        self + [.hardened(index)]
    }
}

public struct HDKeyPath: LosslessStringConvertible, Equatable {

    public var description: String {
        components
            .map(\.description)
            .reduce(into: "m") { acc, item in
                acc += "/" + item
            }
    }

    public let components: [DerivationComponent]

    init(component: DerivationComponent) {
        self.init(components: [component])
    }

    public init(index: Int, hardened: Bool) {
        switch hardened {
        case false:
            self.init(components: [.normal(UInt32(index))])
        case true:
            self.init(components: [.hardened(UInt32(index))])
        }
    }

    public init(components: [DerivationComponent]) {
        self.components = components
    }

    public init?(_ description: String) {
        guard let hdKeyPath = try? Self.from(string: description).get() else {
            return nil
        }
        components = hdKeyPath.components
    }
}

extension HDKeyPath {

    public static func from(string: String) -> Result<Self, HDKeyPathError> {

        let indexParser = Parse {
            "/"
            Int.parser()
        }
        .flatMap { value in
            if value <= Int32.max {
                Always(value)
            } else {
                Fail<Substring, Int>(throwing: HDKeyPathError.invalidIndex)
            }
        }

        let normalDerivationIndexParser = indexParser
            .map(DerivationComponent.normal(intValue:))

        let hardenedDerivationIndexParser = Parse {
            indexParser
            OneOf {
                "'"
                "h"
                "H"
            }
        }
        .map(DerivationComponent.hardened(intValue:))

        let derivationIndexParser = OneOf {
            hardenedDerivationIndexParser
            normalDerivationIndexParser
        }

        let pathComponentsParser = Parse {
            OneOf {
                "M"
                "m"
            }
            Many { derivationIndexParser }
            Optionally { "/" }
        }
        .map(\.0)

        return Result { try pathComponentsParser.parse(string) }
            .mapError(HDKeyPathError.parsingError)
            .map(HDKeyPath.from(components:))
    }
}

extension HDKeyPath {

    static func from(components: [DerivationComponent]) -> Self {
        Self(components: components)
    }
}

extension HDKeyPath {

    func with(normal index: UInt32) -> Self {
        HDKeyPath(components: components + [.normal(index)])
    }

    func with(hardened index: UInt32) -> Self {
        HDKeyPath(components: components + [.hardened(index)])
    }
}

extension Result where Success == HDKeyPath {

    func with(normal index: UInt32) -> Result<Success, Failure> {
        map { path -> Success in
            path.with(normal: index)
        }
    }

    func with(hardened index: UInt32) -> Result<Success, Failure> {
        map { path -> Success in
            path.with(hardened: index)
        }
    }
}
