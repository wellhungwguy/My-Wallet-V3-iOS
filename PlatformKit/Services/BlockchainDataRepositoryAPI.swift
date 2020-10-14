//
//  BlockchainDataRepositoryAPI.swift
//  PlatformKit
//
//  Created by Paulo on 06/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public protocol DataRepositoryAPI {
    var userSingle: Single<User> { get }
    var user: Observable<User> { get }
    
    /// Fetches the NabuUser over the network and updates the cached NabuUser if successful
    ///
    /// - Returns: the fetched NabuUser
    func fetchNabuUser() -> Single<NabuUser>
    var nabuUserSingle: Single<NabuUser> { get }
}
