// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation

public protocol BlockchainDomainsAdapter {

    var associatedDomains: AnyPublisher<[String], Never> { get }
    var claimEligibility: AnyPublisher<Bool, Never> { get }
    var canCompleteTier2: AnyPublisher<Bool, Never> { get }
}

extension BlockchainDomainsAdapter {

    public func numberOfAssociatedDomains() -> AnyPublisher<Int, Never> {
        associatedDomains
            .map(\.count)
            .eraseToAnyPublisher()
    }

    public var state: AnyPublisher<BlockchainDomainsAdapterState, Never> {
        claimEligibility
            .flatMap { [stateForNonEligible] eligible -> AnyPublisher<BlockchainDomainsAdapterState, Never> in
                if eligible {
                    return .just(.readyToClaimDomain)
                }
                return stateForNonEligible
            }
            .eraseToAnyPublisher()
    }

    private var stateForNonEligible: AnyPublisher<BlockchainDomainsAdapterState, Never> {
        canCompleteTier2
            .flatMap { [associatedDomains] canCompleteTier2 -> AnyPublisher<BlockchainDomainsAdapterState, Never> in
                if canCompleteTier2 {
                    return .just(.kycForClaimDomain)
                }
                return associatedDomains
                    .map { associatedDomains -> BlockchainDomainsAdapterState in
                        if associatedDomains.isEmpty {
                            return .unavailable
                        }
                        return .domainsClaimed(associatedDomains)
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}

// in order
public enum BlockchainDomainsAdapterState {
    case readyToClaimDomain // If user is checkClaimEligibility
    case kycForClaimDomain // If user is !checkClaimEligibility and canCompleteTier2
    case domainsClaimed([String]) // If user has claimed domains
    case unavailable // else
}
