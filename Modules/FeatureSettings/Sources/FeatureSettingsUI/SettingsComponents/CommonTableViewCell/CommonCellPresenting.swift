// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitectureExtensions
import Combine

protocol CommonCellPresenting: AsyncPresenting {
    var subtitle: AnyPublisher<LoadingState<String>, Never> { get }
}
