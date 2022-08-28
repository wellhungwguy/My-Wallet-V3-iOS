import Foundation
import PathKit
import XcodeProj // @tuist ~> 8.0.0

print("Adding swift package test targets to schemes")

enum Error: Swift.Error {
    case invalidModule
}

private let decoder = JSONDecoder()

/// Run an xcrun command
/// - Parameter command: The command to run, comma separated rather than spaces.
/// - Returns: SDOUT or SDERR contents as Data
private func xcrun(command: String...) -> Data {
    let process = Process()
    let pipe = Pipe()

    process.standardOutput = pipe
    process.standardError = pipe
    process.arguments = command
    process.launchPath = "/usr/bin/xcrun"
    process.environment = ["OS_ACTIVITY_MODE": "disable"]

    print("⌛️", "xcrun", command.joined(separator: " "))

    process.launch()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()

    return data
}

/// Minimum data needed from swift package description
private struct Package: Decodable {
    let targets: [Target]

    struct Target: Decodable {
        let name: String
        let type: String
    }
}

/// Extract swift package description
/// - Parameter path: Folder containing swift package
/// - Throws: JSON Decoding errors
/// - Returns: A `Package` struct describing the containing swift package
private func packageDump(path: String) throws -> Package {
    let data = xcrun(command: "swift", "package", "dump-package", "--package-path", "Modules/\(path)")
    var output = String(decoding: data, as: UTF8.self)
    var errorDescription: String?
    if !output.hasPrefix("{"), let bracket = output.firstIndex(of: "{") {
        output = String(output[bracket...])
        errorDescription = String(output[...bracket])
    }
    do {
        return try decoder.decode(Package.self, from: Data(output.utf8))
    } catch {
        print("❌", path)
        print(errorDescription ?? output)
        throw error
    }
}

extension Path {

    /// Check if this path is a swift package
    fileprivate func containsSwiftPackage() throws -> Bool {
        try isDirectory && children().lazy.map(\.lastComponent).contains("Package.swift")
    }

    /// The name of the folder the swift package is in
    fileprivate func swiftPackageModule() throws -> String {
        guard !components.isEmpty else {
            throw Error.invalidModule
        }

        return components[1]
    }

    /// The test targets the swift package contains
    fileprivate func swiftPackageTestTargets() throws -> [String] {
        let module = try swiftPackageModule()
        let package = try packageDump(path: module)
        return package.targets
            .filter { $0.type == "test" }
            .map(\.name)
    }
}

/// Create `xcodeproj` testable references from given modules path
/// - Parameter modules: Directory containing all project modules
/// - Returns: An array of testable references for injecting into a project's schemes.
private func testableReferences(in modules: Path) throws -> [XCScheme.TestableReference] {
    try modules.children()
        .reduce(into: []) { result, path in

            guard try path.containsSwiftPackage() else {
                return
            }

            let module = try path.swiftPackageModule()
            let targets = try path.swiftPackageTestTargets()

            targets.forEach { target in

                let reference = XCScheme.BuildableReference(
                    referencedContainer: "container:Modules/\(module)",
                    blueprintIdentifier: target,
                    buildableName: target,
                    blueprintName: target
                )
                let testableReference = XCScheme.TestableReference(
                    skipped: false,
                    parallelizable: false,
                    randomExecutionOrdering: true,
                    buildableReference: reference
                )

                print("Found \(module): \(target)")
                result.append(testableReference)
            }
        }
}

do {
    let path = Path("Blockchain.xcodeproj")
    let xcodeproj = try XcodeProj(path: path)

    let modules = Path("Modules")
    let testableReferences = try testableReferences(in: modules)

    xcodeproj.sharedData?.schemes
        .filter { $0.name.hasPrefix("Blockchain") }
        .forEach { scheme in
            print("Adding to \(scheme.name)")
            scheme.testAction?.testables.append(contentsOf: testableReferences)
        }

    try xcodeproj.write(path: path)
} catch {
    print("Error: \(error)")
    exit(0)
}

print("Done!")
