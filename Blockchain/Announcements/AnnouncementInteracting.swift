// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine

protocol AnnouncementInteracting {
    var preliminaryData: AnyPublisher<AnnouncementPreliminaryData, Error> { get }
}
