// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import ToolKit

public enum RNGEntropyError: Error, Equatable {
    case invalid
    case unableToGenerate
    case networkFailure(ServerEntropyError)
    case parsingFailed(EntropyParsing)
}

public enum EntropyParsing: Error, Equatable {
    case serverEntropyEmpty
    case localEntropyEmpty
    case serverEntropyInvalid
    case localEntropyInvalid
    case invalidLengths
    case parsingFailed
}

typealias EntropyProvider = (_ count: Int) -> AnyPublisher<Data, RNGEntropyError>

protocol RNGServiceAPI {
    /// Generates a new entropy for the requested bytes with a default format of `hex`
    /// - Returns: `AnyPublisher<Data, RNGEntropyError>`
    func generateEntropy(
        count: Int
    ) -> AnyPublisher<Data, RNGEntropyError>

    /// Generates a new entropy for the requested bytes and format
    /// - Returns: `AnyPublisher<Data, RNGEntropyError>`
    func generateEntropy(
        bytes: EntropyBytes,
        format: EntropyFormat
    ) -> AnyPublisher<Data, RNGEntropyError>
}

typealias RandomNumberGenerator = (
    _ count: Int
) -> Result<String, RNGEntropyError>

typealias LocalEntropyProvider = (
    _ bytes: EntropyBytes
) -> AnyPublisher<Data, RNGEntropyError>

typealias CombineEntropyParser = (
    _ local: Data,
    _ remote: Data
) -> Result<Data, EntropyParsing>

final class RNGService: RNGServiceAPI {

    private let serverEntropyRepository: ServerEntropyRepositoryAPI
    private let localEntropyProvider: LocalEntropyProvider
    private let combineEntropyParsing: CombineEntropyParser
    private let operationQueue: DispatchQueue

    init(
        serverEntropyRepository: ServerEntropyRepositoryAPI,
        localEntropyProvider: @escaping LocalEntropyProvider = provideLocalEntropy,
        combineEntropyParsing: @escaping CombineEntropyParser = combineEntropies,
        operationQueue: DispatchQueue
    ) {
        self.serverEntropyRepository = serverEntropyRepository
        self.localEntropyProvider = localEntropyProvider
        self.combineEntropyParsing = combineEntropyParsing
        self.operationQueue = operationQueue
    }

    func generateEntropy(
        count: Int
    ) -> AnyPublisher<Data, RNGEntropyError> {
        generateEntropy(
            bytes: .custom(count),
            format: .hex
        )
    }

    func generateEntropy(
        bytes: EntropyBytes,
        format: EntropyFormat
    ) -> AnyPublisher<Data, RNGEntropyError> {
        serverEntropyRepository.getServerEntropy(bytes: bytes, format: format)
            .mapError(RNGEntropyError.networkFailure)
            .receive(on: operationQueue)
            .map(Data.init(hex:))
            .combineLatest(localEntropyProvider(bytes))
            .flatMap { [combineEntropyParsing] serverEntropy, localEntropy -> AnyPublisher<Data, RNGEntropyError> in
                combineEntropyParsing(localEntropy, serverEntropy)
                    .publisher
                    .mapError(RNGEntropyError.parsingFailed)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}

/// Generates a `Data` value with random bytes
/// - Parameter bytes: The count of the bytes
/// - Returns: `AnyPublisher<Data, RNGEntropyError>`
func provideLocalEntropy(
    bytes: EntropyBytes
) -> AnyPublisher<Data, RNGEntropyError> {
    secureRandomNumberGenerator(count: bytes.value)
        .map(\.toHexString)
        .map(Data.init(hex:))
        .publisher
        .eraseToAnyPublisher()
}

/// Combines two entropies into one using `xor`
/// - Parameters:
///   - local: A `Data` representing a local source entropy
///   - remote: A `Data` representing a remote source entropy
/// - Returns: `Result<Data, EntropyParsing>`
func combineEntropies(
    local: Data,
    remote: Data
) -> Result<Data, EntropyParsing> {
    guard !remote.isEmpty else {
        return .failure(.serverEntropyEmpty)
    }
    guard !local.isEmpty else {
        return .failure(.localEntropyEmpty)
    }
    guard !remote.allSatisfy({ $0 == remote[0] }) else {
        return .failure(.serverEntropyInvalid)
    }
    guard !local.allSatisfy({ $0 == local[0] }) else {
        return .failure(.localEntropyInvalid)
    }
    guard remote.count == local.count else {
        return .failure(.invalidLengths)
    }
    let combinedEntropy = xor(left: local, right: remote)
    guard !combinedEntropy.allSatisfy({ $0 == combinedEntropy[0] }) else {
        return .failure(.parsingFailed)
    }
    return .success(combinedEntropy)
}

/// A simple `xor` method
/// - Parameters:
///   - left: Some Data to be processed
///   - right: Some Data to be processed
/// - Returns: A `Data` output of left and right parameters
func xor(left: Data, right: Data) -> Data {
    let length = min(left.count, right.count)
    var final = Data(count: length)

    for i in 0..<length {
        final[i] = left[i] ^ right[i]
    }
    return final
}

/// Generates a random number using `SecRandomCopyBytes`
/// - Parameter count: The count for the returned number
/// - Returns: Returns a `Result<Data, RNGEntropyError>`
func secureRandomNumberGenerator(count: Int) -> Result<Data, RNGEntropyError> {
    let data = Data(
        [UInt8].secureRandomBytes(count: count)
    )
    guard data.count == count else {
        return .failure(.unableToGenerate)
    }
    return .success(data)
}

extension Array where Element == UInt8 {
    /// Returns an Array of random UInt8 elements by using `SecRandomCopyBytes`
    /// - Parameter count: The count of the random bytes
    /// - Returns: An array of UInt8 elements
    public static func secureRandomBytes(count: Int) -> Array {
        Array(unsafeUninitializedCapacity: count) { buffer, initializedCount in
            let result = SecRandomCopyBytes(kSecRandomDefault, count, buffer.baseAddress!)
            initializedCount = (result == errSecSuccess) ? count : 0
        }
    }
}

