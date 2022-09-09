// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Algorithms
import BlockchainComponentLibrary
import BlockchainNamespace
import Collections
import Combine
import DIKit
import Examples
import SwiftUI
import ToolKit

// swiftlint:disable force_try

public protocol NetworkDebugScreenProvider {
    @ViewBuilder func buildDebugView() -> AnyView
}

struct DebugView: View {

    var window: UIWindow?

    @State var pulse: Bool = false
    @State var layoutDirection: LayoutDirection = .leftToRight

    var body: some View {
        PrimaryNavigationView {
            ScrollView {
                VStack {
                    PrimaryNavigationLink(
                        destination: FeatureFlags()
                            .primaryNavigation(title: "⛳️ Feature Flags")
                    ) {
                        PrimaryRow(title: "⛳️ Feature Flags")
                    }
                    PrimaryDivider()
                    PrimaryNavigationLink(
                        destination: Examples.RootView.content
                            .environment(\.layoutDirection, layoutDirection)
                            .primaryNavigation(title: "📚 Component Library") {
                                Button(layoutDirection == .leftToRight ? "➡️" : "⬅️") {
                                    layoutDirection = layoutDirection == .leftToRight ? .rightToLeft : .leftToRight
                                }
                            }
                    ) {
                        PrimaryRow(title: "📚 Component Library")
                    }
                    PrimaryDivider()
                    PrimaryRow(title: "🤖 Pulse") {
                        pulse = true
                    }
                }
                .background(Color.semantic.background)
            }
            .sheet(isPresented: $pulse) {
                Pulse()
                    .ignoresSafeArea()
                    .onDisappear {
                        pulse = false
                    }
            }
            .primaryNavigation(title: "Debug") {
                Button(window?.overrideUserInterfaceStyle == .dark ? "☀️" : "🌑") {
                    if let window = window {
                        switch window.overrideUserInterfaceStyle {
                        case .dark:
                            window.overrideUserInterfaceStyle = .light
                        default:
                            window.overrideUserInterfaceStyle = .dark
                        }
                    }
                }
            }
        }
        .app(resolve())
    }
}

extension DebugView {

    struct NamespaceState: View {

        @BlockchainApp var app

        let pasteboard = UIPasteboard.general

        @StateObject var observer: StateObserver = .init()

        func description(for key: Tag.Reference) -> String {
            var string = ""
            if key.indices.isNotEmpty {
                string += key.indices
                    .filter { tag, _ in key.tag != tag }
                    .map { key, value in "\(key.id): \(value)" }
                    .joined(separator: "\n")
            }
            string += observer.data[key]?.pretty ?? JSON.null.pretty
            return string
        }

        var body: some View {
            if observer.data.isEmpty {
                ProgressView().onAppear { observer.observe(on: app) }
            }
            ForEach(observer.data.keys, id: \.self) { key in
                PrimaryRow(
                    title: try! key.tag.idRemainder(after: blockchain[])
                        .replacingOccurrences(of: "app.configuration.", with: "")
                        .replacingOccurrences(of: ".", with: " ")
                        .replacingOccurrences(of: "_", with: " "),
                    description: description(for: key),
                    trailing: {
                        switch key.tag {
                        case blockchain.db.type.boolean:
                            PrimarySwitch(
                                accessibilityLabel: key.string,
                                isOn: app.binding(key).isYes
                            )
                        default:
                            EmptyView()
                        }
                    }
                )
                .contextMenu {
                    Button(
                        action: { pasteboard.string = key.string },
                        label: {
                            Label("Copy Name", systemImage: "doc.on.doc.fill")
                        }
                    )
                    Button(
                        action: { pasteboard.string = observer.data[key]?.pretty },
                        label: {
                            Label("Copy", systemImage: "doc.on.doc.fill")
                        }
                    )
                    if key.tag.is(blockchain.session.state.value) {
                        Button(
                            action: { app.state.clear(key) },
                            label: {
                                Label("Clear", systemImage: "trash.fill")
                            }
                        )
                    }
                }
            }
        }
    }

    class StateObserver: ObservableObject {

        @Published var data: OrderedDictionary<Tag.Reference, JSON> = [:]

        private var isFetching = false
        private var subscription: AnyCancellable?

        init() {}

        func observe(on app: AppProtocol) {
            guard subscription.isNil else { return }
            subscription = app.publisher(for: blockchain.app.configuration.debug.observers, as: [Tag.Reference?].self)
                .compactMap(\.value)
                .flatMap { events in events.compacted().map(app.publisher(for:)).combineLatest() }
                .map { results in
                    results.reduce(into: [:]) { sum, result in
                        sum[result.metadata.ref] = try? result.value.decode(JSON.self)
                    }
                }
                .receive(on: DispatchQueue.main)
                .sink { [weak self] results in
                    self?.data = results
                }
        }
    }

    struct FeatureFlags: View {

        @BlockchainApp var app
        @State var data: [AppFeature: JSON] = [:]

        var body: some View {
            ScrollView {
                VStack {
                    namespace
                    Section(header: Text("Remote").typography(.title2)) {
                        remote
                    }
                }
                PrimaryButton(title: "Reset to default") {
                    app.remoteConfiguration.clear()
                }
                .padding()
            }
            .listRowInsets(
                EdgeInsets(
                    top: 0,
                    leading: 0,
                    bottom: 0,
                    trailing: 0
                )
            )
            .background(Color.semantic.background)
        }

        let pasteboard = UIPasteboard.general

        @ViewBuilder var namespace: some View {
            NamespaceState()
        }

        @ViewBuilder var remote: some View {
            ForEach(AppFeature.allCases, id: \.self) { feature in
                let name = feature.remoteEnabledKey
                Group {
                    if let value = data[feature] {
                        PrimaryRow(
                            title: name,
                            subtitle: value.description,
                            trailing: {
                                if value.isBoolean {
                                    PrimarySwitch(
                                        accessibilityLabel: name,
                                        isOn: Binding<Bool>(
                                            get: { try! app.remoteConfiguration.get(name) as! Bool },
                                            set: { newValue in app.remoteConfiguration.override(name, with: newValue) }
                                        )
                                    )
                                }
                            }
                        )
                        .typography(.caption1)
                        .contextMenu {
                            Button(
                                action: { pasteboard.string = name },
                                label: {
                                    Label("Copy Name", systemImage: "doc.on.doc.fill")
                                }
                            )
                            Button(
                                action: { pasteboard.string = value.description },
                                label: {
                                    Label("Copy JSON", systemImage: "doc.on.doc.fill")
                                }
                            )
                        }
                    } else {
                        PrimaryRow(
                            title: name,
                            trailing: { ProgressView() }
                        )
                        .typography(.caption1)
                    }
                }
                .onReceive(
                    app.remoteConfiguration
                        .publisher(for: name)
                        .tryMap { output in try output.decode(JSON.self) }
                        .replaceError(with: .null)
                ) { json in
                    data[feature] = json
                }
            }
        }
    }

    struct Pulse: View {
        @Inject var networkDebugScreenProvider: NetworkDebugScreenProvider

        var body: some View {
            networkDebugScreenProvider.buildDebugView()
        }
    }
}

enum JSON: Codable, Equatable, CustomStringConvertible {

    case null
    case boolean(Bool)
    case string(String)
    case number(NSNumber)
    case array([JSON])
    case object([String: JSON])

    var isBoolean: Bool {
        if case .boolean = self { return true }
        return false
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            self = .null
        } else if let boolean = try? container.decode(Bool.self) {
            self = .boolean(boolean)
        } else if let int = try? container.decode(Int.self) {
            self = .number(NSNumber(value: int))
        } else if let double = try? container.decode(Double.self) {
            self = .number(NSNumber(value: double))
        } else if let string = try? container.decode(String.self) {
            self = .string(string)
        } else if let array = try? container.decode([JSON].self) {
            self = .array(array)
        } else if let object = try? container.decode([String: JSON].self) {
            self = .object(object)
        } else {
            throw DecodingError.typeMismatch(
                JSON.self,
                .init(
                    codingPath: decoder.codingPath,
                    debugDescription: "Expected to decode JSON value"
                )
            )
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .null:
            try container.encodeNil()
        case .boolean(let bool):
            try container.encode(bool)
        case .number(let number):
            switch CFNumberGetType(number) {
            case .intType, .nsIntegerType, .sInt8Type, .sInt16Type, .sInt32Type, .sInt64Type:
                try container.encode(number.intValue)
            default:
                try container.encode(number.doubleValue)
            }
        case .string(let string):
            try container.encode(string)
        case .array(let array):
            try container.encode(array)
        case .object(let object):
            try container.encode(object)
        }
    }

    var pretty: String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        do {
            return String(decoding: try encoder.encode(self), as: UTF8.self)
        } catch {
            return "<invalid json>"
        }
    }

    var description: String { pretty }
}

extension AppProtocol {

    func binding(_ event: Tag.Event) -> Binding<Any?> {
        let key = event.key()
        switch key.tag {
        case blockchain.session.state.value, blockchain.db.collection.id:
            return state.binding(event)
        case blockchain.session.configuration.value:
            return remoteConfiguration.binding(event)
        default:
            return .constant(nil)
        }
    }
}

extension Session.RemoteConfiguration {

    func binding(_ event: Tag.Event) -> Binding<Any?> {
        Binding(
            get: { [unowned self] in try? get(event) },
            set: { [unowned self] newValue in override(event, with: newValue as Any) }
        )
    }
}

extension Session.State {

    func binding(_ event: Tag.Event) -> Binding<Any?> {
        Binding(
            get: { [unowned self] in try? get(event) },
            set: { [unowned self] newValue in set(event, to: newValue as Any) }
        )
    }
}

extension Binding where Value == Any? {

    func decode<T: Decodable>(
        as type: T.Type = T.self,
        using decoder: AnyDecoderProtocol = BlockchainNamespaceDecoder()
    ) -> Binding<T?> {
        Binding<T?>(
            get: { try? wrappedValue.decode(T.self, using: decoder) },
            set: { newValue in wrappedValue = newValue }
        )
    }

    var isYes: Binding<Bool> {
        Binding<Bool>(
            get: { (try? wrappedValue.decode(Bool.self)) == true },
            set: { newValue in wrappedValue = newValue }
        )
    }
}
