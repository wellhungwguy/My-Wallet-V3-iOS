// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AVKit
import CasePaths
import NukeUI
import SwiftUI
import UniformTypeIdentifiers

public typealias Media = NukeUI.Image

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
            source: url,
            content: { state in
                withTransaction(transaction) {
                    Group {
                        if let image = state.image {
                            content(.success(image))
                        } else if let error = state.error {
                            content(.failure(error))
                        } else {
                            content(.empty)
                        }
                    }
                }
            }
        )
    }
}

extension AsyncMedia {

    public init(
        url: URL?
    ) where Content == _ConditionalContent<Media, ProgressView<EmptyView, EmptyView>> {
        self.init(url: url, placeholder: { ProgressView() })
    }

    public init<I: View, P: View>(
        url: URL?,
        @ViewBuilder content: @escaping (Media) -> I,
        @ViewBuilder placeholder: @escaping () -> P
    ) where Content == _ConditionalContent<I, P> {
        self.init(url: url) { phase in
            if case .success(let media) = phase {
                content(media)
            } else {
                placeholder()
            }
        }
    }

    public init<P: View>(
        url: URL?,
        @ViewBuilder placeholder: @escaping () -> P
    ) where Content == _ConditionalContent<Media, P> {
        self.init(
            url: url,
            content: { phase in
                if case .success(let media) = phase {
                    media
                } else {
                    placeholder()
                }
            }
        )
    }
}

extension URL {

    var uniformTypeIdentifier: UTType? { UTType(filenameExtension: pathExtension) }
}
