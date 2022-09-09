// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public enum DeepLinkRoute: CaseIterable {
    case kyc
    case kycVerifyEmail
    case kycDocumentResubmission
    case openBankingLink
    case openBankingApprove
}

extension DeepLinkRoute {

    public static func route(
        from url: String,
        supportedRoutes: [DeepLinkRoute] = DeepLinkRoute.allCases
    ) -> DeepLinkRoute? {
        guard let url = URL(string: url) else {
            return nil
        }

        let fragment = url.fragment.flatMap { fragment in
            URL(string: fragment)
        }

        let path: String
        let parameters: [String: String]

        if let fragment = fragment {
            path = fragment.path
            parameters = url.queryArgs.merging(fragment.queryArgs, uniquingKeysWith: { $1 })
        } else {
            path = url.path
            parameters = url.queryArgs
        }

        return DeepLinkRoute.route(
            path: path,
            parameters: parameters,
            supportedRoutes: supportedRoutes
        )
    }

    private static func route(
        path: String,
        parameters: [String: String]?,
        supportedRoutes: [DeepLinkRoute] = DeepLinkRoute.allCases
    ) -> DeepLinkRoute? {
        supportedRoutes.first { route -> Bool in
            guard path.hasSuffix(route.supportedPath) else {
                return false
            }
            guard let key = route.requiredKeyParam,
                  let value = route.requiredValueParam,
                  let routeParameters = parameters
            else {
                return true
            }
            guard let optionalKey = route.optionalKeyParameter,
                  let value = routeParameters[optionalKey],
                  FlowContext(rawValue: value) != nil
            else {
                return routeParameters[key] == value
            }
            return false
        }
    }

    private var supportedPath: String {
        switch self {
        case .kycVerifyEmail,
             .kycDocumentResubmission:
            return "login"
        case .kyc:
            return "kyc"
        case .openBankingLink:
            return "ob-bank-link"
        case .openBankingApprove:
            return "ob-bank-approval"
        }
    }

    private var requiredKeyParam: String? {
        switch self {
        case .kyc,
             .kycVerifyEmail,
             .kycDocumentResubmission:
            return "deep_link_path"
        case .openBankingLink, .openBankingApprove:
            return nil
        }
    }

    private var requiredValueParam: String? {
        switch self {
        case .kycVerifyEmail:
            return "email_verified"
        case .kycDocumentResubmission:
            return "verification"
        case .kyc:
            return "kyc"
        case .openBankingLink, .openBankingApprove:
            return nil
        }
    }

    private var optionalKeyParameter: String? {
        switch self {
        case .kycVerifyEmail:
            return "context"
        case .kyc,
             .kycDocumentResubmission,
             .openBankingLink,
             .openBankingApprove:
            return nil
        }
    }
}
