// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxCocoa
import RxSwift
import ToolKit

extension ObservableType {

    public func bindAndCatch<A: AnyObject>(
        file: String = #file,
        line: Int = #line,
        function: String = #function,
        weak object: A,
        onNext: @escaping (A, Element) -> Void
    ) -> Disposable {
        _bind(
            onNext: { [weak object] element in
                guard let object else { return }
                onNext(object, element)
            },
            file: file,
            line: line,
            function: function
        )
    }

    public func bindAndCatch<A: AnyObject>(
        file: String = #file,
        line: Int = #line,
        function: String = #function,
        weak object: A,
        onNext: @escaping (A) -> Void
    ) -> Disposable {
        _bind(
            onNext: { [weak object] _ in
                guard let object else { return }
                onNext(object)
            },
            file: file,
            line: line,
            function: function
        )
    }

    private func _bind(
        onNext: @escaping (Element) -> Void,
        file: String = #file,
        line: Int = #line,
        function: String = #function
    ) -> Disposable {
        self.do(onError: { error in
            fatalError("Binding error. file: \(file), line: \(line), function: \(function), error: \(error).")
        })
        .bind(onNext: onNext)
    }
}
