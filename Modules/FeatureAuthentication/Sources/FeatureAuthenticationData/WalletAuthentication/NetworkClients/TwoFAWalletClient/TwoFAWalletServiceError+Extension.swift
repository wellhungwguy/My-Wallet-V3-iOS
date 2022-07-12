// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Errors
import FeatureAuthenticationDomain
import Foundation

extension TwoFAWalletServiceError: FromNetworkError {

    private enum RawErrorSubstring {
        static let accountLocked = "locked"
        static let wrongCode = "attempts left"
    }

    init?(plainServerError: String) {
        if plainServerError.contains(RawErrorSubstring.accountLocked) {
            self = .accountLocked
        } else if plainServerError.contains(RawErrorSubstring.wrongCode) {
            let attemptsLeftString = plainServerError.components(
                separatedBy: CharacterSet.decimalDigits.inverted
            )
            .joined()
            guard let attemptsLeft = Int(attemptsLeftString) else {
                return nil
            }
            self = .wrongCode(attemptsLeft: attemptsLeft)
        } else {
            return nil
        }
    }

    public static func from(_ networkError: NetworkError) -> TwoFAWalletServiceError {
        switch networkError.type {
        case .payloadError(.badData(rawPayload: let payload), _):
            guard let error = TwoFAWalletServiceError(plainServerError: payload) else {
                return .networkError(networkError)
            }
            return error
        case .rawServerError(let response):
            guard let payloadData = response.payload,
                  let payload = String(data: payloadData, encoding: .utf8),
                  let error = TwoFAWalletServiceError(plainServerError: payload)
            else {
                return .networkError(networkError)
            }
            return error
        default:
            return .networkError(networkError)
        }
    }
}
