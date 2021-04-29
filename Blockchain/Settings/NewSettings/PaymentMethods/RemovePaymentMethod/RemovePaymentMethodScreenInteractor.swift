//
//  RemovePaymentMethodScreenInteractor.swift
//  Blockchain
//
//  Created by Alex McGregor on 4/9/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import AnalyticsKit
import BuySellKit
import DIKit
import PlatformKit
import RxRelay
import RxSwift
import ToolKit

final class RemovePaymentMethodScreenInteractor {
    
    typealias State = ValueCalculationState<Void>
            
    let triggerRelay = PublishRelay<Void>()
    
    var state: Observable<State> {
        _ = setup
        return stateRelay.asObservable()
    }
    
    let data: PaymentMethodRemovalData
    
    private let stateRelay = BehaviorRelay<State>(value: .invalid(.empty))
    private let disposeBag = DisposeBag()
    private let eventRecorder: AnalyticsEventRecording
    
    private lazy var setup: Void = {
        stateRelay
            .filter { $0.isValue }
            .take(1)
            .mapToVoid()
            .record(analyticsEvent: data.event, using: eventRecorder)
            .subscribe()
            .disposed(by: disposeBag)
        
        triggerRelay
            .flatMap(weak: self) { (self, _) -> Observable<State> in
                self.remove(data: self.data)
            }
            .bindAndCatch(to: stateRelay)
            .disposed(by: disposeBag)
    }()
    
    // MARK: - Injected
    
    private let deletionService: PaymentMethodDeletionServiceAPI
    
    init(data: PaymentMethodRemovalData,
         deletionService: PaymentMethodDeletionServiceAPI,
         eventRecorder: AnalyticsEventRecording = resolve()) {
        self.deletionService = deletionService
        self.eventRecorder = eventRecorder
        self.data = data
    }
    
    private func remove(data: PaymentMethodRemovalData) -> Observable<State> {
        deletionService.delete(by: data)
            .andThen(.just(.value(())))
            .startWith(.calculating)
            .catchErrorJustReturn(.invalid(.valueCouldNotBeCalculated))
    }
}
