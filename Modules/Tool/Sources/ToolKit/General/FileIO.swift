// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public enum FileIOError: Error {
    case generic
}

public protocol FileIOAPI {
    func write<T: Encodable>(
        _ value: T,
        to fileURL: URL,
        encodedUsing encoder: JSONEncoder
    ) -> Result<Void, FileIOError>

    func read<T: Decodable>(
        to fileURL: URL,
        decodedUsing decoder: JSONDecoder
    ) -> Result<T, FileIOError>
}

struct FileIO: FileIOAPI {
    func write(
        _ value: some Encodable,
        to fileURL: URL,
        encodedUsing encoder: JSONEncoder
    ) -> Result<Void, FileIOError> {
        do {
            let data = try encoder.encode(value)
            try data.write(to: fileURL)
            return .success(())
        } catch {
            return .failure(.generic)
        }
    }

    func read<T: Decodable>(
        to fileURL: URL,
        decodedUsing decoder: JSONDecoder
    ) -> Result<T, FileIOError> {
        do {
            let data = try Data(contentsOf: fileURL, options: .uncached)
            let response = try decoder.decode(T.self, from: data)
            return .success(response)
        } catch {
            return .failure(.generic)
        }
    }
}
