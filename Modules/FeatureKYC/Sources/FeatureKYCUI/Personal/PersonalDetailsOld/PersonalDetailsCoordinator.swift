// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxSwift
import ToolKit

final class PersonalDetailsCoordinator {

    private let disposeBag = DisposeBag()
    private let service: PersonalDetailsService
    private weak var interface: PersonalDetailsInterface?

    init(
        interface: PersonalDetailsInterface,
        service: PersonalDetailsService = PersonalDetailsService()
    ) {
        self.service = service
        self.interface = interface

        if let controller = interface as? KYCPersonalDetailsController {
            controller.delegate = self
        }
    }
}

extension PersonalDetailsCoordinator: PersonalDetailsDelegate {
    func onSubmission(_ input: KYCUpdatePersonalDetailsRequest, completion: @escaping () -> Void) {
        let onSubscribe = { [weak self] in
            self?.interface?.primaryButtonEnabled(false)
            self?.interface?.primaryButtonActivityIndicator(.visible)
        }

        let onDispose = { [weak self] in
            self?.interface?.primaryButtonActivityIndicator(.hidden)
            self?.interface?.primaryButtonEnabled(true)
        }

        service
            .update(
                firstName: input.firstName,
                lastName: input.lastName,
                birthday: input.birthday
            )
            .asObservable()
            .observe(on: MainScheduler.instance)
            .do(onSubscribe: onSubscribe)
            .subscribe(
                onError: { _ in
                    onDispose()
                }, onCompleted: {
                    onDispose()
                    completion()
                }
            )
            .disposed(by: disposeBag)
    }
}
