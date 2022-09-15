// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation

public protocol SeedPhraseValidatorAPI {
    func validate(phrase: String) -> AnyPublisher<MnemonicValidationScore, Never>
}

public final class SeedPhraseValidator: SeedPhraseValidatorAPI {

    // MARK: - Type

    private enum Constant {
        static let seedPhraseLength: Int = 12
    }

    // MARK: - Properties

    private let words: Set<String>

    // MARK: - Setup

    public init(words: Set<String>) {
        self.words = words
    }

    // MARK: - API

    public func validate(phrase: String) -> AnyPublisher<MnemonicValidationScore, Never> {
        if phrase.isEmpty {
            return .just(.none)
        }

        /// Make an array of the individual words
        let components = phrase
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }

        if components.count < Constant.seedPhraseLength {
            return .just(.incomplete)
        }

        if components.count > Constant.seedPhraseLength {
            return .just(.excess)
        }

        /// Separate out the words that are duplicates
        let duplicates = Set(components.duplicates ?? [])

        /// The total number of duplicates entered
        let duplicatesCount = duplicates
            .map { duplicate in
                components.filter { $0 == duplicate }.count
            }
            .reduce(0, +)

        /// Make a set for all the individual entries
        let set = Set(phrase.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty && !duplicates.contains($0) })

        guard !set.isEmpty || duplicatesCount > 0 else {
            return .just(.none)
        }

        /// Are all the words entered thus far valid words
        let entriesAreValid = set.isSubset(of: words) && duplicates.isSubset(of: words)
        if entriesAreValid {
            return .just(.valid)
        }

        /// Combine the `set` and `duplicates` to form a `Set<String>` of all
        /// words that are not included in the `WordList`
        let difference = set.union(duplicates).subtracting(words)

        /// Find the `NSRange` value for each word or incomplete word that is not
        /// included in the `WordList`
        let ranges = difference.map { delta -> [NSRange] in
            phrase.ranges(of: delta)
        }
        .flatMap { $0 }

        return .just(.invalid(ranges))
    }
}

// MARK: - Convenience

extension String {
    /// A convenience function for getting an array of `NSRange` values
    /// for a particular substring.
    fileprivate func ranges(of substring: String) -> [NSRange] {
        var ranges: [Range<Index>] = []
        enumerateSubstrings(in: startIndex..<endIndex, options: .byWords) { word, value, _, _ in
            if let word = word, word == substring {
                ranges.append(value)
            }
        }
        return ranges.map { NSRange($0, in: self) }
    }
}

extension Array where Element: Hashable {
    public var duplicates: [Element]? {
        let dictionary = Dictionary(grouping: self, by: { $0 })
        let pairs = dictionary.filter { $1.count > 1 }
        let duplicates = Array(pairs.keys)
        return !duplicates.isEmpty ? duplicates : nil
    }
}
