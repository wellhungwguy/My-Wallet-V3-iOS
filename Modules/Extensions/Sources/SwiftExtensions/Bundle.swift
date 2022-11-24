// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Algorithms
import Foundation

extension Bundle {

    public var plist: InfoPlist! { try? InfoPlist(in: self) }

    /// The application version. Equivalent to CFBundleShortVersionString.
    public static var applicationVersion: String? {
        main.plist.version.description
    }

    /// The build version of the application. Equivalent to CFBundleVersion.
    public static var applicationBuildVersion: String? {
        main.plist.build
    }

    /// The name of the application. Equivalent to CFBundleDisplayName.
    public static var applicationName: String? {
        main.plist.name
    }
}

@dynamicMemberLookup
public struct InfoPlist {

    public var version: Version
    public var build: String
    public var name: String

    private let source: [String: Any]

    public init(source: [String: Any]) throws {
        self.source = source
        self.version = try Version(
            string: source["CFBundleShortVersionString"]
                .as(String.self)
                .or(throw: Error.missing(key: "CFBundleShortVersionString"))
        )
        self.build = try source["CFBundleVersion"]
            .as(String.self)
            .or(throw: Error.missing(key: "CFBundleVersion"))
        self.name = try source["CFBundleDisplayName"]
            .as(String.self)
            .or(throw: Error.missing(key: "CFBundleDisplayName"))
    }

    public subscript(dynamicMember string: String) -> Any? {
        source[string]
    }
}

extension InfoPlist {

    public init(in bundle: Bundle = Bundle.main) throws {
        guard let source = bundle.infoDictionary else {
            throw Error.missingInfoDictionary
        }
        self = try .init(source: source)
    }

    public enum Error: Swift.Error {
        case missingInfoDictionary
        case missing(key: String)
    }
}

extension Foundation.Bundle {

    /// Returns the resource bundle associated with a Swift module.
    public static func find(_ bundleNames: String..., in type: AnyObject.Type) -> Bundle {

        let candidates = [
            // Bundle should be present here when the package is linked into an App.
            Bundle.main.resourceURL,

            // Bundle should be present here when the package is linked into a framework.
            Bundle(for: type).resourceURL,

            // For command-line tools.
            Bundle.main.bundleURL,

            // For SwiftUI previews
            Bundle(for: type).resourceURL?
                .deletingLastPathComponent()
                .deletingLastPathComponent()
                .deletingLastPathComponent(),

            Bundle(for: type).resourceURL?
                .deletingLastPathComponent()
                .deletingLastPathComponent()
        ]

        for (candidate, bundleName) in product(candidates, bundleNames) {
            let bundlePath = candidate?.appendingPathComponent(bundleName)
            if let bundle = bundlePath.flatMap(Bundle.init(url:)) {
                return bundle
            }
        }

        fatalError("unable to find bundle named \(bundleNames)")
    }
}

extension Bundle {

    public func url(for resource: (name: String, extension: String)) -> URL? {
        url(forResource: resource.name, withExtension: resource.extension)
    }
}

extension String {

    public var fileNameAndExtension: (name: String, extension: String) {
        guard let extIndex = lastIndex(of: ".") else { return (self, "") }
        return (String(self[..<extIndex]), String(self[extIndex...]))
    }
}
