//
//  NabuAPIError.swift
//  PlatformKit
//
//  Created by Daniel on 26/06/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import NetworkKit

enum NabuAuthenticationError: Int, Error {
    
    /// 401
    case tokenExpired = 401
    
    /// 409
    case alreadyRegistered = 409
    
    init?(communicatorError: NetworkCommunicatorError) {
        guard case .rawServerError(let serverError) = communicatorError else {
            return nil
        }
        guard let authenticationError = NabuAuthenticationError(rawValue: serverError.response.statusCode) else {
            return nil
        }
        self = authenticationError
    }
}

