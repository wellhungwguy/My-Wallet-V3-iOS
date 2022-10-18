// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import FeatureQRCodeScannerDomain
import PlatformKit
import ToolKit

public final class CryptoTargetQRCodeParser: QRCodeScannerParsing {

    public enum CryptoTargetParserError: Error {
        case unableToCreatePayload
        case noAvailableAccount
    }

    private let account: CryptoAccount?
    private let adapter: CryptoTargetQRCodeParserAdapter
    private var cancellables = [AnyCancellable]()

    public init(
        account: CryptoAccount?,
        adapter: CryptoTargetQRCodeParserAdapter = resolve()
    ) {
        self.account = account
        self.adapter = adapter
    }

    public func parse(
        scanResult: Result<String, QRScannerError>
    ) -> AnyPublisher<QRCodeScannerResultType, QRScannerError> {
        if let account {
            return parse(account: account, scanResult: scanResult)
        }

        return scanResult.publisher
            .flatMap { [adapter] address -> AnyPublisher<QRCodeScannerResultType, QRScannerError> in
                adapter
                    .availableAccounts
                    .flatMap { [adapter] accounts -> AnyPublisher<[Result<QRCodeParserTarget, QRScannerError>], Never> in
                        accounts
                            .compactMap { $0 as? CryptoAccount }
                            .map { account in
                                adapter
                                    .createAndValidate(fromString: address, account: account)
                                    .mapToResult()
                            }
                            .zip()
                    }
                    .map { results -> [QRCodeParserTarget] in
                        results.compactMap { targetResult -> QRCodeParserTarget? in
                            guard case .success(let target) = targetResult else {
                                return nil
                            }
                            if case .address(let account, let receiveAddress) = target {
                                if receiveAddress is BitPayInvoiceTarget {
                                    return account.isBitPaySupported ? target : nil
                                }
                            }
                            return target
                        }
                    }
                    .mapError(QRScannerError.parserError)
                    .receive(on: DispatchQueue.main)
                    .flatMap { targets -> AnyPublisher<QRCodeScannerResultType, QRScannerError> in
                        guard let target = targets.first else {
                            return .failure(.parserError(CryptoTargetParserError.noAvailableAccount))
                        }
                        if targets.count == 1 {
                            return .just(.cryptoTarget(target))
                        }
                        return .just(.cryptoTargets(targets))
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    private func parse(
        account: CryptoAccount,
        scanResult: Result<String, QRScannerError>
    ) -> AnyPublisher<QRCodeScannerResultType, QRScannerError> {
        scanResult.publisher
            .flatMap { [adapter] address -> AnyPublisher<QRCodeScannerResultType, QRScannerError> in
                adapter.create(fromString: address, account: account)
                    .map { target -> QRCodeScannerResultType in
                        .cryptoTarget(target)
                    }
                    .mapError(QRScannerError.parserError)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
