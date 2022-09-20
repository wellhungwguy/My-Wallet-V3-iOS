import Foundation

extension URLRequest {

    /// The cURL representation of the URLRequest, useful for debugging and executing requests outside of the app.
    public var cURLCommand: String {

        var command = "curl"

        if let httpMethod = httpMethod {
            command.append(commandLineArgument: "-X \(httpMethod)")
        }

        if let httpBody = httpBody, httpBody.isNotEmpty {
            let bodyString = [("\\", "\\\\"), ("`", "\\`"), ("\"", "\\\""), ("$", "\\$")].reduce(String(data: httpBody, encoding: .utf8)) {
                $0?.replacingOccurrences(of: $1.0, with: $1.1)
            }!
            command.append(commandLineArgument: "-d \"\(bodyString)\"")
        }

        if let acceptEncoderHeader = allHTTPHeaderFields?["Accept-Encoding"], (acceptEncoderHeader as NSString).range(of: "gzip").location != NSNotFound {
            command.append(commandLineArgument: "--compressed")
        }

        if let url = url, let cookies = HTTPCookieStorage.shared.cookies(for: url), cookies.isNotEmpty {
            command.append(
                commandLineArgument: "--cookie \"\(cookies.map { "\($0.name)=\($0.value);" }.joined())\""
            )
        }

        if let allHTTPHeaderFields = allHTTPHeaderFields {
            for (header, value) in allHTTPHeaderFields {
                command.append(commandLineArgument: "-H '\(header): \(value.replacingOccurrences(of: "\'", with: "\\\'"))'")
            }
        }

        if let url = url {
            command.append(commandLineArgument: "\"\(url.absoluteString)\"")
        }
        return command
    }
}

extension String {

    fileprivate mutating func append(commandLineArgument: String) {
        append(" \(commandLineArgument.trimmingCharacters(in: CharacterSet.whitespaces))")
    }
}
