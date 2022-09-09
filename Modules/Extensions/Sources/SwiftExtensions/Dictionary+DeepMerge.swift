import Foundation

public struct DeepMapOptions: OptionSet {

    public let rawValue: UInt
    public init(rawValue: UInt) { self.rawValue = rawValue }

    public static let mappingOverArrays = DeepMapOptions(rawValue: 1 << 0)
    public static let all: DeepMapOptions = [.mappingOverArrays]
}

extension Dictionary where Value == Any {

    @inlinable public func deepMerging(
        _ other: Self,
        uniquingKeysWith policy: (Value, Value) -> Value
    ) -> Self {
        merging(other) { old, new in
            if let old = old as? Self, let new = new as? Self {
                return old.deepMerging(new, uniquingKeysWith: policy)
            } else {
                return policy(old, new)
            }
        }
    }

    @inlinable public func deepMap(
        _ options: DeepMapOptions = [.mappingOverArrays],
        _ transform: (Key, Value) throws -> (Key, Value)
    ) rethrows -> Self {
        try reduce(into: [Key: Value](minimumCapacity: count)) { dictionary, next in
            let (key, value) = try transform(next.key, next.value)
            switch value {
            case let o as Self:
                dictionary[key] = try o.deepMap(options, transform)
            case let o as [Self] where options.contains(.mappingOverArrays):
                dictionary[key] = try o.map { try $0.deepMap(options, transform) }
            default:
                dictionary[key] = value
            }
        }
    }

    @inlinable public func deepMapAndMerge(
        _ options: DeepMapOptions = [.mappingOverArrays],
        _ transform: (Key, Value) throws -> (Key, Value),
        uniquingKeysWith policy: (Value, Value) -> Value = { $1 }
    ) rethrows -> Self {
        try reduce(into: [Key: Value](minimumCapacity: count)) { dictionary, next in
            let (key, value) = try transform(next.key, next.value)
            switch value {
            case let o as Self:
                let mapped = try o.deepMapAndMerge(options, transform, uniquingKeysWith: policy)
                if let x = dictionary[key] as? Self {
                    dictionary[key] = x.deepMerging(mapped, uniquingKeysWith: policy)
                } else {
                    dictionary[key] = mapped
                }
            case let o as [Self] where options.contains(.mappingOverArrays):
                dictionary[key] = try o.map {
                    try $0.deepMapAndMerge(options, transform, uniquingKeysWith: policy)
                }
            default:
                dictionary[key] = value
            }
        }
    }
}
