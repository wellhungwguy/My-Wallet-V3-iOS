// Copyright © Blockchain Luxembourg S.A. All rights reserved.
// swiftlint:disable all

import SwiftUI

extension View {

    public func withGeometry<A, V: View>(
        updating update: GeometryUpdate = .onAppear,
        @ViewBuilder content: @escaping (Self, GeometryProxy) -> V
    ) -> some View {
        WithGeometry(self, geometry: { $0 }, update: update, content: content)
    }

    public func withGeometry<A, V: View>(
        _ transform: @escaping (GeometryProxy) -> A,
        updating update: GeometryUpdate = .onAppear,
        @ViewBuilder content: @escaping (Self, A) -> V
    ) -> some View {
        WithGeometry(self, geometry: transform, update: update, content: content)
    }

    public func withGeometry<A, B, V: View>(
        _ a: @escaping (GeometryProxy) -> A,
        _ b: @escaping (GeometryProxy) -> B,
        updating update: GeometryUpdate = .onAppear,
        @ViewBuilder content: @escaping (Self, A, B) -> V
    ) -> some View {
        WithGeometry(self, geometry: { (a($0), b($0)) }, update: update) {
            content($0, $1.0, $1.1)
        }
    }

    public func withGeometry<A, B, C, V: View>(
        _ a: @escaping (GeometryProxy) -> A,
        _ b: @escaping (GeometryProxy) -> B,
        _ c: @escaping (GeometryProxy) -> C,
        updating update: GeometryUpdate = .onAppear,
        @ViewBuilder content: @escaping (Self, A, B, C) -> V
    ) -> some View {
        WithGeometry(self, geometry: { (a($0), b($0), c($0)) }, update: update) {
            content($0, $1.0, $1.1, $1.2)
        }
    }

    public func withGeometry<A, B, C, D, V: View>(
        _ a: @escaping (GeometryProxy) -> A,
        _ b: @escaping (GeometryProxy) -> B,
        _ c: @escaping (GeometryProxy) -> C,
        _ d: @escaping (GeometryProxy) -> D,
        updating update: GeometryUpdate = .onAppear,
        @ViewBuilder content: @escaping (Self, A, B, C, D) -> V
    ) -> some View {
        WithGeometry(self, geometry: { (a($0), b($0), c($0), d($0)) }, update: update) {
            content($0, $1.0, $1.1, $1.2, $1.3)
        }
    }

    public func withGeometry<A, B, C, D, E, V: View>(
        _ a: @escaping (GeometryProxy) -> A,
        _ b: @escaping (GeometryProxy) -> B,
        _ c: @escaping (GeometryProxy) -> C,
        _ d: @escaping (GeometryProxy) -> D,
        _ e: @escaping (GeometryProxy) -> E,
        updating update: GeometryUpdate = .onAppear,
        @ViewBuilder content: @escaping (Self, A, B, C, D, E) -> V
    ) -> some View {
        WithGeometry(self, geometry: { (a($0), b($0), c($0), d($0), e($0)) }, update: update) {
            content($0, $1.0, $1.1, $1.2, $1.3, $1.4)
        }
    }

    public func withGeometry<A, B, C, D, E, F, V: View>(
        _ a: @escaping (GeometryProxy) -> A,
        _ b: @escaping (GeometryProxy) -> B,
        _ c: @escaping (GeometryProxy) -> C,
        _ d: @escaping (GeometryProxy) -> D,
        _ e: @escaping (GeometryProxy) -> E,
        _ f: @escaping (GeometryProxy) -> F,
        updating update: GeometryUpdate = .onAppear,
        @ViewBuilder content: @escaping (Self, A, B, C, D, E, F) -> V
    ) -> some View {
        WithGeometry(self, geometry: { (a($0), b($0), c($0), d($0), e($0), f($0)) }, update: update) {
            content($0, $1.0, $1.1, $1.2, $1.3, $1.4, $1.5)
        }
    }

    public func withGeometry<A, B, C, D, E, F, G, V: View>(
        _ a: @escaping (GeometryProxy) -> A,
        _ b: @escaping (GeometryProxy) -> B,
        _ c: @escaping (GeometryProxy) -> C,
        _ d: @escaping (GeometryProxy) -> D,
        _ e: @escaping (GeometryProxy) -> E,
        _ f: @escaping (GeometryProxy) -> F,
        _ g: @escaping (GeometryProxy) -> G,
        updating update: GeometryUpdate = .onAppear,
        @ViewBuilder content: @escaping (Self, A, B, C, D, E, F, G) -> V
    ) -> some View {
        WithGeometry(self, geometry: { (a($0), b($0), c($0), d($0), e($0), f($0), g($0)) }, update: update) {
            content($0, $1.0, $1.1, $1.2, $1.3, $1.4, $1.5, $1.6)
        }
    }
}

public enum GeometryUpdate {
    case onAppear
    case onChange
}

struct WithGeometry<T, Base: View, Content: View>: View {

    var base: Base
    var transform: (GeometryProxy) -> T
    var content: (Base, T) -> Content
    var update: GeometryUpdate

    init(
        _ base: Base,
        geometry transform: @escaping (GeometryProxy) -> T,
        update: GeometryUpdate,
        @ViewBuilder content: @escaping (Base, T) -> Content
    ) {
        self.base = base
        self.transform = transform
        self.update = update
        self.content = content
    }

    @State private var value: T? = nil

    var body: some View {
        _content
            .background(
                GeometryReader { geometry in
                    switch update {
                    case .onAppear:
                        Color.clear.onAppear { value = transform(geometry) }
                    case .onChange:
                        Color.clear
                            .preference(key: GeometrySizePreferenceKey.self, value: geometry.size)
                            .onPreferenceChange(GeometrySizePreferenceKey.self) { _ in value = transform(geometry) }
                    }
                }
            )
    }

    @ViewBuilder
    var _content: some View {
        if let value = value {
            content(base, value)
        } else {
            base
        }
    }
}

struct GeometrySizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}
