import Extensions
import class Foundation.Bundle

private class BundleFinder {}

extension Foundation.Bundle {
    public static let namespace = Bundle.find(
        "BlockchainNamespace_BlockchainNamespace.bundle",
        "Blockchain_BlockchainNamespace.bundle",
        in: BundleFinder.self
    )
}

// The following is copied from `ToolKit` to avoid adding an extra external dependency into the Exchange app
extension Foundation.Bundle {

    /// Returns the resource bundle associated with a Swift module.
    private static func find(_ bundleNames: String..., in type: AnyObject.Type) -> Bundle {

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
