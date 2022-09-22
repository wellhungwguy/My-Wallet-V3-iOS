// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import Foundation

/// Composable State for Prefetching
public struct PrefetchingState: Equatable {

    // Internal properties

    let debounce: DispatchQueue.SchedulerTimeType.Stride
    let fetchMargin: Int

    var seen: Set<Int> = []
    var fetchedIndices: Set<Int> = []

    // Public properties

    /// Valid indices for fetching. Usually `content.indices` from a list's array data source.
    /// Avoids index out of bounds errors. `nil` disables fetch ahead/behind margin.
    /// Set in init, or update in your own reducer.
    public var validIndices: Range<Int>?

    /// Create state required for prefetching content in a list.
    /// - Parameters:
    ///   - debounce: debounce time from `onAppear / onDisappear` before fetching. Defaults to 0.5
    ///   - fetchMargin: Distance ahead and behind visible items to fetch. Default 10
    ///   - validIndices: Valid indices for fetching. Usually `content.indices` from a list's array data source.
    ///                   `nil` disables fetch ahead/behind margins, and thus only fetches visible indices.
    ///                   `public var validIndices` is updatable on-the fly with your own reducer.
    public init(
        debounce: DispatchQueue.SchedulerTimeType.Stride = 0.5,
        fetchMargin: Int = 10,
        validIndices: Range<Int>? = nil
    ) {
        self.debounce = debounce
        self.fetchMargin = fetchMargin
        self.validIndices = validIndices
    }
}
