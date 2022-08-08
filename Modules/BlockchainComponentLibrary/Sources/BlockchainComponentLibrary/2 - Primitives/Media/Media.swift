// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AVKit
import CasePaths
import NukeUI
import SwiftUI
import UniformTypeIdentifiers

public typealias Media = NukeUI.Image

@MainActor
public struct AsyncMedia<Content: View>: View {

    private let url: URL?
    private let transaction: Transaction
    private let content: (AsyncPhase<Media>) -> Content

    public init(
        url: URL?,
        transaction: Transaction = Transaction(),
        @ViewBuilder content: @escaping (AsyncPhase<Media>) -> Content
    ) {
        self.url = url
        self.transaction = transaction
        self.content = content
    }

    public var body: some View {
        LazyImage(
            url: url,
            content: { state in
                withTransaction(transaction) {
                    which(state)
                }
            }
        )
    }

    @ViewBuilder
    private func which(_ state: LazyImageState) -> some View {
        if let image = state.image {
            content(.success(image.resizingMode(.aspectFit)))
        } else if let error = state.error {
            content(.failure(error))
        } else {
            content(.empty)
        }
    }
}

extension AsyncMedia {

    public init(
        url: URL?,
        transaction: Transaction = Transaction()
    ) where Content == _ConditionalContent<Media, ProgressView<EmptyView, EmptyView>>? {
        self.init(url: url, transaction: transaction, placeholder: { ProgressView() })
    }

    public init<I: View, P: View>(
        url: URL?,
        transaction: Transaction = Transaction(),
        @ViewBuilder content: @escaping (Media) -> I,
        @ViewBuilder placeholder: @escaping () -> P
    ) where Content == _ConditionalContent<_ConditionalContent<I, EmptyView>, P> {
        self.init(url: url, transaction: transaction, content: content, failure: { _ in EmptyView() }, placeholder: placeholder)
    }

    public init<I: View, F: View, P: View>(
        url: URL?,
        transaction: Transaction = Transaction(),
        @ViewBuilder content: @escaping (Media) -> I,
        @ViewBuilder failure: @escaping (Error) -> F,
        @ViewBuilder placeholder: @escaping () -> P
    ) where Content == _ConditionalContent<_ConditionalContent<I, F>, P> {
        self.init(url: url, transaction: transaction) { phase in
            switch phase {
            case .success(let media):
                content(media)
            case .failure(let error):
                failure(error)
            case .empty:
                placeholder()
            }
        }
    }

    public init<P: View>(
        url: URL?,
        transaction: Transaction = Transaction(),
        @ViewBuilder placeholder: @escaping () -> P
    ) where Content == _ConditionalContent<Media, P>? {
        self.init(
            url: url,
            transaction: transaction,
            content: { phase in
                if case .success(let media) = phase {
                    media
                } else if case .empty = phase {
                    placeholder()
                }
            }
        )
    }
}

extension URL {

    var uniformTypeIdentifier: UTType? { UTType(filenameExtension: pathExtension) }
}
