// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxCocoa
import RxRelay
import RxSwift
import ToolKit

public final class SelectionScreenPresenter {

    // MARK: - Properties

    let title: String
    let tableHeaderViewModel: SelectionScreenTableHeaderViewModel?
    let searchBarPlaceholder: String
    var presenters: Observable<[SelectionItemViewPresenter]> {
        presentersRelay.asObservable()
    }

    var displayPresenters: Observable<[SelectionItemViewPresenter]> {
        displayPresentersRelay.asObservable()
    }

    var preselection: Observable<Int> {
        Observable.combineLatest(selectionRelay, preselectionSupportedRelay)
            .filter(\.1)
            .compactMap(\.0)
            .observe(on: MainScheduler.instance)
    }

    var selection: Observable<Int> {
        Observable.combineLatest(selectionRelay, preselectionSupportedRelay)
            .filter { !$0.1 }
            .compactMap(\.0)
            .observe(on: MainScheduler.instance)
    }

    let dismissRelay = PublishRelay<Void>()
    var dismiss: Signal<Void> {
        dismissRelay.asSignal()
    }

    let searchTextRelay = BehaviorRelay<String>(value: "")
    var searchText: Observable<String> {
        searchTextRelay.map { $0.lowercased() }
    }

    let preSelectionRelay = PublishRelay<Int>()
    private var shouldPreselect: Bool
    private let preselectionSupportedRelay = BehaviorRelay<Bool>(value: true)
    private let selectionRelay = BehaviorRelay<Int?>(value: nil)
    private let displayPresentersRelay = BehaviorRelay<[SelectionItemViewPresenter]>(value: [])
    private let presentersRelay = BehaviorRelay<[SelectionItemViewPresenter]>(value: [])
    private let interactor: SelectionScreenInteractor
    private let disposeBag = DisposeBag()

    // MARK: - Setup

    public init(
        title: String,
        description: String? = nil,
        shouldPreselect: Bool = true,
        searchBarPlaceholder: String,
        interactor: SelectionScreenInteractor
    ) {
        self.shouldPreselect = shouldPreselect
        preselectionSupportedRelay.accept(shouldPreselect)
        tableHeaderViewModel = SelectionScreenTableHeaderViewModel(title: description)
        self.searchBarPlaceholder = searchBarPlaceholder
        self.title = title
        self.interactor = interactor

        setupPresenters()
        setupSearch()

        if shouldPreselect {
            setupDefaultSelection()
        }
    }

    private func setupPresenters() {
        interactor.interactors
            .map { interactors in
                interactors.map { SelectionItemViewPresenter(interactor: $0) }
            }
            .bindAndCatch(to: presentersRelay)
            .disposed(by: disposeBag)

        presentersRelay
            .filter { !$0.isEmpty }
            .take(1)
            .bindAndCatch(weak: self) { (self, presenters) in
                presenters
                    .enumerated()
                    .forEach { index, presenter in
                        presenter.setup {
                            let previousIndex = self.selectionRelay.value
                            guard previousIndex != index else { return }

                            presenters[index].select()
                            self.selectionRelay.accept(index)

                            if let previousIndex {
                                self.dismissRelay.accept(())
                                presenters[previousIndex].deselect()
                            } else if !self.shouldPreselect {
                                self.dismissRelay.accept(())
                            }
                        }
                    }
            }
            .disposed(by: disposeBag)
    }

    private func setupSearch() {
        searchText
            .flatMapLatest(weak: self) { (self, text) in
                self.presenters
                    .map { presenters in
                        guard !text.isEmpty else {
                            return presenters
                        }
                        return presenters.filter { $0.contains(text: text) }
                    }
            }
            .bindAndCatch(to: displayPresentersRelay)
            .disposed(by: disposeBag)
    }

    private func setupDefaultSelection() {

        let presenters = presenters
            .filter { !$0.isEmpty }

        let selectedIndex = Observable
            .zip(
                presenters.take(1),
                interactor.service.selectedDataRelay.take(1)
            )
            .compactMap { presenters, selectedData in
                presenters.firstIndex { $0.data == selectedData }
            }
            .share(replay: 1)

        Observable
            .zip(
                presenters,
                selectedIndex
            )
            .take(1)
            .bind { presenters, selectedIndex in
                presenters[selectedIndex].select()
            }
            .disposed(by: disposeBag)

        selectedIndex
            .bindAndCatch(to: selectionRelay)
            .disposed(by: disposeBag)
    }

    func previousTapped() {
        interactor.recordSelection()
        interactor.dissmisRelay.accept(())
    }
}
