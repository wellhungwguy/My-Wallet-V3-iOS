// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import StoreKit
import ToolKit

public protocol SkAdNetworkServiceAPI {
    func firstTimeRegister()
    func update(with conversionValue: Int)
}

public class SkAdNetworkService: SkAdNetworkServiceAPI {
    private var errorRecorder: Recording

    public init(errorRecorder: Recording) {
        self.errorRecorder = errorRecorder
    }

    public func firstTimeRegister() {
        SKAdNetwork.registerAppForAdNetworkAttribution()
    }

    public func update(with conversionValue: Int) {
        errorRecorder.record("updating SKAdNetwork with value \(conversionValue)")

        if #available(iOS 15.4, *) {
            SKAdNetwork.updatePostbackConversionValue(conversionValue) { [weak self] error in
                if let error {
                    self?.errorRecorder.record("SkAdNetwork update failed with \(error.localizedDescription)")
                    self?.errorRecorder.error(error)
                }
            }
        } else {
            SKAdNetwork.updateConversionValue(conversionValue)
        }
    }
}
