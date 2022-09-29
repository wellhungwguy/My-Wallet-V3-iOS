// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Combine
import ComposableArchitecture
import Errors
import PlatformKit

struct IdentityVerificationEnvironment {
    let onCompletion: () -> Void
    let supportedDocumentTypes: () -> AnyPublisher<[KYCDocumentType], NabuNetworkError>
    let analyticsRecorder: AnalyticsEventRecorderAPI
    let mainQueue: AnySchedulerOf<DispatchQueue>
}
