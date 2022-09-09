import Foundation

extension RawRepresentable where RawValue == String {

    @inlinable public var string: String { rawValue }
}
