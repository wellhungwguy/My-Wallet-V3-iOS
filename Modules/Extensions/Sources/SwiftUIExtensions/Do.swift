// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

// swiftlint:disable type_name
/// Try to load a view. On failure catch the error and display the failure case.
/// Allows in-line SwiftUI usage of do-catch syntax
///
/// Do {
///     try WebView(url: tab.ref.context.decode(blockchain.ux.web.id))
/// } catch: { error in
///     maintenance(tab)
/// }
public struct Do<Success: View, Failure: View>: View {

    public let success: () throws -> Success
    public let failure: (Error) -> Failure

    public var body: some View {
        switch Result(catching: { try success() }) {
        case .success(let view):
            view
        case .failure(let error):
            failure(error)
        }
    }

    public init(
        @ViewBuilder try success: @escaping () throws -> Success,
        @ViewBuilder catch failure: @escaping (Error) -> Failure
    ) {
        self.success = success
        self.failure = failure
    }
}
