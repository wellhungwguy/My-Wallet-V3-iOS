// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import MoneyKit
import RxRelay
import RxSwift
import ToolKit

public protocol PaymentMethodDeletionServiceAPI: AnyObject {
    /// Deletes a payment-method with a given removal data
    func delete(by data: PaymentMethodRemovalData) -> Completable
}

public protocol BeneficiariesServiceAPI: PaymentMethodDeletionServiceAPI {

    /// Streams the beneficiaries
    var beneficiaries: Observable<[Beneficiary]> { get }

    /// Keeps updating a new value of whether the user has at least one linked bank
    var hasLinkedBank: Observable<Bool> { get }

    /// Streams the available currencies for bank linkage
    var availableCurrenciesForBankLinkage: Observable<Set<FiatCurrency>> { get }

    /// Fetch beneficiaries once, but other subscribers to `beneficiaries` would get the new value
    func fetch() -> Observable<[Beneficiary]>

    // Invalidate the caches to update the beneficiary and linked bank
    func invalidate()
}

final class BeneficiariesService: BeneficiariesServiceAPI {

    // MARK: - Properties

    let beneficiaries: Observable<[Beneficiary]>

    let hasLinkedBank: Observable<Bool>

    let availableCurrenciesForBankLinkage: Observable<Set<FiatCurrency>>

    private let beneficiariesRelay = BehaviorRelay<[Beneficiary]?>(value: nil)
    private let paymentMethodTypesService: PaymentMethodTypesServiceAPI
    private let client: BeneficiariesClientAPI
    private let linkedBankService: LinkedBanksServiceAPI
    private let beneficiariesServiceUpdater: BeneficiariesServiceUpdaterAPI

    // MARK: - Setup

    init(
        client: BeneficiariesClientAPI = resolve(),
        linkedBankService: LinkedBanksServiceAPI = resolve(),
        paymentMethodTypesService: PaymentMethodTypesServiceAPI = resolve(),
        beneficiariesServiceUpdater: BeneficiariesServiceUpdaterAPI = resolve()
    ) {
        self.client = client
        self.linkedBankService = linkedBankService
        self.paymentMethodTypesService = paymentMethodTypesService
        self.beneficiariesServiceUpdater = beneficiariesServiceUpdater

        NotificationCenter.when(.logout) { [weak beneficiariesRelay] _ in
            beneficiariesRelay?.accept(nil)
        }

        let paymentMethodsShared = paymentMethodTypesService.methodTypes
            .share(replay: 1, scope: .whileConnected)

        let fetchBeneficiaries: Observable<[Beneficiary]> = Observable
            .combineLatest(
                client.beneficiaries.asObservable(),
                paymentMethodsShared,
                linkedBankService.fetchLinkedBanks().asObservable()
            )
            .map(concat(beneficiaries:methodTypes:linkedBanks:))
            .do(
                onNext: { _ in
                    beneficiariesServiceUpdater.reset()
                },
                afterNext: { [weak beneficiariesRelay] beneficiaries in
                    beneficiariesRelay?.accept(beneficiaries)
                }
            )
            .catchAndReturn([])

        beneficiaries = beneficiariesRelay
            .withLatestFrom(beneficiariesServiceUpdater.shouldRefresh) { ($0, $1) }
            .flatMap { beneficiaries, shouldUpdate -> Observable<[Beneficiary]> in
                guard !shouldUpdate else {
                    return fetchBeneficiaries.asObservable()
                }
                guard let beneficiaries else {
                    return fetchBeneficiaries.asObservable()
                }
                return .just(beneficiaries)
            }
            .distinctUntilChanged()
            .share(replay: 1, scope: .whileConnected)

        availableCurrenciesForBankLinkage = paymentMethodsShared
            .map { methodTypes in
                Set(methodTypes.suggestedFunds)
            }
            .share(replay: 1, scope: .whileConnected)

        hasLinkedBank = beneficiaries
            .map { !$0.isEmpty }
    }

    func fetch() -> Observable<[Beneficiary]> {
        performFetch()
            .do(afterNext: { [weak self] beneficiaries in
                self?.beneficiariesRelay.accept(beneficiaries)
            })
    }

    func delete(by data: PaymentMethodRemovalData) -> Completable {
        guard case .beneficiary(let accountType) = data.type else {
            return .just(event: .completed)
        }
        return deleteBank(by: data.id, for: accountType)
            .andThen(fetch().take(1))
            .do(onNext: { [weak self] _ in
                self?.paymentMethodTypesService.clearPreferredPaymentIfNeeded(by: data.id)
            })
            .ignoreElements()
            .asCompletable()
    }

    // MARK: - Private

    private func performFetch() -> Observable<[Beneficiary]> {
        Observable
            .combineLatest(
                client.beneficiaries.asObservable(),
                paymentMethodTypesService.methodTypes,
                linkedBankService.fetchLinkedBanks().asObservable()
            )
            .map(concat(beneficiaries:methodTypes:linkedBanks:))
            .catchAndReturn([])
    }

    private func deleteBank(by id: String, for accountType: Beneficiary.AccountType) -> Completable {
        switch accountType {
        case .funds:
            return client.deleteBank(by: id).asObservable().ignoreElements().asCompletable()
        case .linkedBank:
            return linkedBankService.deleteBank(by: id)
        }
    }

    func invalidate() {
        beneficiariesRelay.accept(nil)
        linkedBankService.invalidate()
        beneficiariesServiceUpdater.markForRefresh()
    }
}

/// Concatenates any beneficiaries and any linked banks from `methodTypes` into a single array of `Beneficiary`
/// - Parameters:
///   - beneficiaries: An array containing beneficiaries responses
///   - methodTypes: An array containing payment method tyoes
/// - Returns: An array of `Beneficiary` elements as a result of the contatenation
private func concat(
    beneficiaries: [BeneficiaryResponse],
    methodTypes: [PaymentMethodType],
    linkedBanks: [LinkedBankData]
) -> [Beneficiary] {
    var limitsByBaseFiat: [FiatCurrency: FiatValue] = [:]
    let topLimits = methodTypes.accounts.map(\.topLimit)
    for limit in topLimits {
        limitsByBaseFiat[limit.currency] = limit
    }
    let activeLinkedBank = linkedBanks.filter(\.isActive)

    let linkedBanksResult: [Beneficiary] = activeLinkedBank.map {
        Beneficiary(linkedBankData: $0)
    }

    let result: [Beneficiary] = beneficiaries.compactMap {
        guard let currency = FiatCurrency(code: $0.currency) else { return nil }
        return Beneficiary(response: $0, limit: limitsByBaseFiat[currency])
    }
    let identifiers = result.map(\.identifier)
    let linkedBanks = linkedBanksResult.filter { !identifiers.contains($0.identifier) }
    return result + linkedBanks
}
