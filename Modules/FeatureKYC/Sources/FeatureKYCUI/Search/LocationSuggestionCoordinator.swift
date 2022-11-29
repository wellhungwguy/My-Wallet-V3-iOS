// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import PlatformUIKit
import RxSwift
import ToolKit

protocol LocationSuggestionCoordinatorDelegate: AnyObject {
    func coordinator(_ locationCoordinator: LocationSuggestionCoordinator, updated model: LocationSearchResult)
    func coordinator(_ locationCoordinator: LocationSuggestionCoordinator, generated address: PostalAddress)
}

class LocationSuggestionCoordinator {

    private let locationSuggestionService: LocationSuggestionService
    private let locationUpdateService: LocationUpdateService
    private var model: LocationSearchResult {
        didSet {
            delegate?.coordinator(self, updated: model)
        }
    }

    private weak var delegate: LocationSuggestionCoordinatorDelegate?
    private weak var interface: LocationSuggestionInterface?

    private let disposeBag = DisposeBag()

    init(
        _ delegate: LocationSuggestionCoordinatorDelegate,
        interface: LocationSuggestionInterface,
        locationUpdateService: LocationUpdateService = LocationUpdateService(),
        locationSuggestionService: LocationSuggestionService = LocationSuggestionService()
    ) {
        self.locationUpdateService = locationUpdateService
        self.locationSuggestionService = locationSuggestionService
        self.delegate = delegate
        self.interface = interface
        self.model = .empty

        if let controller = delegate as? KYCAddressController {
            controller.searchDelegate = self
        }
    }
}

extension LocationSuggestionCoordinator: SearchControllerDelegate {

    func onStart() {
        interface?.primaryButton(.hidden)
        switch model.suggestions.isEmpty {
        case true:
            interface?.searchFieldText(nil)
            interface?.suggestionsList(.hidden)
            interface?.termsOfServiceDisclaimer(.visible)
            interface?.addressEntryView(.visible)
        case false:
            interface?.termsOfServiceDisclaimer(.hidden)
            interface?.suggestionsList(.visible)
            interface?.addressEntryView(.hidden)
        }
    }

    func onSubmission(_ selection: SearchSelection) {
        var newModel = model
        newModel.state = .loading
        model = newModel

        if let input = selection as? LocationSuggestion {
            locationSuggestionService.fetchAddress(from: input) { _ in
                // TODO: May no longer be necessary
            }
        }
    }

    func onSelection(_ selection: SearchSelection) {
        if let input = selection as? LocationSuggestion {
            interface?.searchFieldText("")
            interface?.suggestionsList(.hidden)
            interface?.updateActivityIndicator(.visible)
            locationSuggestionService.fetchAddress(from: input) { [weak self] address in
                guard let this = self else { return }
                this.interface?.termsOfServiceDisclaimer(.visible)
                this.interface?.addressEntryView(.visible)
                this.interface?.primaryButton(.visible)
                this.interface?.updateActivityIndicator(.hidden)
                this.interface?.searchFieldActive(false)
                this.interface?.populateAddressEntryView(address)
            }
        }
    }

    func onSubmission(_ address: UserAddress, completion: @escaping () -> Void) {
        let onSubscribe = { [weak self] in
            self?.interface?.primaryButtonEnabled(false)
            self?.interface?.primaryButtonActivityIndicator(.visible)
        }

        let onDispose = { [weak self] in
            self?.interface?.primaryButtonActivityIndicator(.hidden)
            self?.interface?.primaryButtonEnabled(true)
        }

        let onError = { [weak self] error in
            self?.interface?.didReceiveError(error)
        }

        locationUpdateService
            .update(address: address)
            .observe(on: MainScheduler.instance)
            .do(onSubscribe: onSubscribe)
            .subscribe(
                onCompleted: {
                    onDispose()
                    completion()
                },
                onError: { error in
                    onError(error)
                    onDispose()
                }
            )
            .disposed(by: disposeBag)
    }

    func onSubmission(_ address: PostalAddress) {
        delegate?.coordinator(self, generated: address)
    }

    func onSearchRequest(_ query: String) {
        var newModel = model
        newModel.state = .loading
        model = newModel

        if model.suggestions.isEmpty {
            interface?.addressEntryView(.hidden)
            interface?.updateActivityIndicator(.visible)
        }

        if locationSuggestionService.isExecuting {
            locationSuggestionService.cancel()
        }

        locationSuggestionService.search(for: query) { [weak self] suggestions, error in
            guard let this = self else { return }

            let state: LocationSearchResult.SearchUIState = error != nil ? .error(error) : .success
            let empty: [LocationSuggestion] = []

            let result = LocationSearchResult(
                state: state,
                suggestions: suggestions ?? empty
            )

            let listVisibility: Visibility = suggestions != nil ? .visible : .hidden
            let termsVisibility: Visibility = suggestions != nil ? .hidden : .visible
            this.interface?.updateActivityIndicator(.hidden)
            this.interface?.suggestionsList(listVisibility)
            this.interface?.termsOfServiceDisclaimer(termsVisibility)
            this.model = result
        }
    }

    func onSearchResigned() {
        switch model.suggestions.isEmpty {
        case true:
            interface?.suggestionsList(.hidden)
            interface?.termsOfServiceDisclaimer(.visible)
            interface?.addressEntryView(.visible)
            interface?.primaryButton(.visible)
        case false:
            interface?.termsOfServiceDisclaimer(.hidden)
            interface?.suggestionsList(.visible)
            interface?.addressEntryView(.hidden)
            interface?.primaryButton(.hidden)
        }
    }

    func onSearchViewCancel() {
        interface?.searchFieldActive(false)
        interface?.suggestionsList(.hidden)
        interface?.termsOfServiceDisclaimer(.visible)
        interface?.primaryButton(.visible)
        interface?.addressEntryView(.visible)
        guard locationSuggestionService.isExecuting else { return }
        locationSuggestionService.cancel()
    }
}
