import MoneyKit

public struct BIND: Codable, Hashable {

    public struct Attributes: Codable, Hashable {
        public let name: String
        public let documentId: String
    }

    public let accountHolder: String
    public let accountNumber: String
    public let accountType: String
    public let address: String
    public let bankName: String
    public let currency: FiatCurrency
    public let extraAttributes: Attributes
    public let isOwner: Bool
    public let label: String
}

extension BIND {

    public static var preview: BIND {
        BIND(
            accountHolder: "Diaz, Bruno",
            accountNumber: "3220001823000055910025",
            accountType: "Cuenta corriente",
            address: "3220001823000055910025",
            bankName: "BANCO INDUSTRIAL S.A.",
            currency: .ARS,
            extraAttributes: BIND.Attributes(
                name: "Diaz, Bruno",
                documentId: "20223385072"
            ),
            isOwner: true,
            label: "BOCHA.ASTRO.NUEZ"
        )
    }
}
