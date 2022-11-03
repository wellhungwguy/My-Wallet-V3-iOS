// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension UserDefaults {
    public func set(codable: (some Encodable)?, forKey key: String) {
        let encoder = JSONEncoder()
        guard codable != nil else {
            set(nil, forKey: key)
            return
        }
        do {
            let data = try encoder.encode(codable)
            let jsonString = String(data: data, encoding: .utf8)!
            set(jsonString, forKey: key)
        } catch {
            Logger.shared.error("Saving \"\(key)\" failed: \(error)")
        }
    }

    public func codable<T: Decodable>(_ codable: T.Type, forKey key: String) -> T? {
        guard let jsonString = string(forKey: key) else { return nil }
        guard let data = jsonString.data(using: .utf8) else { return nil }
        let decoder = JSONDecoder()
        return try? decoder.decode(codable, from: data)
    }
}
