// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import KeychainKit

public class KeychainAccessMock: KeychainAccessAPI {
    public required init(service: String) {}
    public required init(queryProvider: KeychainQueryProvider) {}
    public required init(service: String, accessGroup: String) {}

    public var readCalled: Bool = false
    public var readResult: Result<Data, KeychainAccessError> = .failure(.readFailure(.itemNotFound(account: "")))
    public func read(
        for key: String
    ) -> Result<Data, KeychainAccessError> {
        readCalled = true
        return readResult
    }

    public var writeCalled: Bool = false
    public var writeResult: Result<Void, KeychainAccessError> = .failure(.readFailure(.itemNotFound(account: "")))
    public func write(
        value: Data,
        for key: String
    ) -> Result<Void, KeychainAccessError> {
        writeCalled = true
        return writeResult
    }

    public var removeCalled: Bool = false
    public var removeResult: Result<Void, KeychainAccessError> = .failure(.readFailure(.itemNotFound(account: "")))
    public func remove(
        for key: String
    ) -> Result<Void, KeychainAccessError> {
        removeCalled = true
        return removeResult
    }
}
