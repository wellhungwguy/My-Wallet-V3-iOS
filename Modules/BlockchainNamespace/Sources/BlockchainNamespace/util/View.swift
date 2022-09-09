#if canImport(SwiftUI)

import SwiftUI

public typealias BlockchainApp = EnvironmentObject<App.EnvironmentObject>

extension App {

    public class EnvironmentObject: NSObject, ObservableObject, AppProtocol {

        let app: AppProtocol

        public var language: Language { app.language }
        public var events: Session.Events { app.events }
        public var state: Session.State { app.state }
        public var observers: Session.Observers { app.observers }
        public var remoteConfiguration: Session.RemoteConfiguration { app.remoteConfiguration }
        public var environmentObject: App.EnvironmentObject { self }
        public var deepLinks: DeepLink { app.deepLinks }

        public init(_ app: AppProtocol) {
            self.app = app
            super.init()
        }
    }
}

extension View {

    public func app(_ app: AppProtocol) -> some View {
        environmentObject(app.environmentObject)
    }

    public func context(_ context: Tag.Context) -> some View {
        environment(\.context, context)
    }
}

extension EnvironmentValues {

    public var context: Tag.Context {
        get { self[BlockchainAppContext.self] }
        set { self[BlockchainAppContext.self] += newValue }
    }
}

public struct BlockchainAppContext: EnvironmentKey {
    public static let defaultValue: Tag.Context = [:]
}
#endif
