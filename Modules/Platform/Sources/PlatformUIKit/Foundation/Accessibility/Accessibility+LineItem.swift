// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension Accessibility.Identifier {
    public enum LineItem {
        public enum Base {}
        public enum Transactional {}
    }
}

extension Accessibility.Identifier.LineItem.Base {
    private static let prefix = "LineItem."

    public static let titleLabel = "\(prefix)titleLabel"
    public static let descriptionLabel = "\(prefix)descriptionLabel"
    public static let disclaimerLabel = "\(prefix)disclaimerLabel"
    public static let disclaimerImage = "\(prefix)disclaimerImage"
}

extension Accessibility.Identifier.LineItem.Transactional {
    private static let prefix = "LineItem."

    public static let themeBackgroundImageView = "\(prefix)themeBackgroundImageView"
    public static let bankName = "\(prefix)bankName"
    public static let iban = "\(prefix)iban"
    public static let bankCountry = "\(prefix)bankCountry"
    public static let accountNumber = "\(prefix)accountNumber"
    public static let sortCode = "\(prefix)sortCode"
    public static let bankCode = "\(prefix)bankCode"
    public static let routingNumber = "\(prefix)routingNumber"
    public static let recipient = "\(prefix)recipient"
    public static let amountToSend = "\(prefix)amountToSend"
    public static let date = "\(prefix)date"
    public static let totalCost = "\(prefix)totalCost"
    public static let total = "\(prefix)total"
    public static let gasFor = "\(prefix)gasFor"
    public static let memo = "\(prefix)memo"
    public static let from = "\(prefix)from"
    public static let to = "\(prefix)to"
    public static let estimatedAmount = "\(prefix)estimatedAmount"
    public static let amount = "\(prefix)amount"
    public static let `for` = "\(prefix)for"
    public static let buyingFee = "\(prefix)buyingFee"
    public static let networkFee = "\(prefix)networkFee"
    public static let exchangeRate = "\(prefix)exchangeRate"
    public static let paymentMethod = "\(prefix)paymentMethod"
    public static let recurringBuyFrequency = "\(prefix)recurringBuyFrequency"
    public static let orderId = "\(prefix)orderId"
    public static let sendingTo = "\(prefix)sendingTo"
    public static let status = "\(prefix)status"
    public static let bankTransfer = "\(prefix)bankTransfer"
    public static let pending = "\(prefix)pending"
    public static let cryptoAmount = "\(prefix)cryptoAmount"
    public static let fiatAmount = "\(prefix)fiatAmount"
    public static let value = "\(prefix)value"
    public static let fee = "\(prefix)fee"
    public static let availableToTrade = "\(prefix)availableToTrade"
    public static let cryptoPrice = "\(prefix)cryptoPrice"
}
