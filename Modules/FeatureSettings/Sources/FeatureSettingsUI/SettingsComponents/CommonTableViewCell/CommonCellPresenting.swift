// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ComposableArchitectureExtensions

protocol CommonCellPresenting: AsyncPresenting {
    var subtitle: AnyPublisher<LoadingState<String>, Never> { get }
}
