public struct BINDBeneficiary: Codable, Hashable {

    public struct Agent: Codable, Hashable {
        public let address, label, holderDocument: String
        public let name, bankName, accountType: String
    }

    public let id: String
    public let agent: Agent
}

extension BINDBeneficiary {

    public static var preview: BINDBeneficiary {
        BINDBeneficiary(
            id: "448316a6-4e09-45c5-aa18-37200cf2add3",
            agent: BINDBeneficiary.Agent(
                address: "3220001801000020816205",
                label: "BOCHA.ASTRO.NUEZ",
                holderDocument: "20203385072",
                name: "Parker, Peter",
                bankName: "BANCO INDUSTRIAL S.A.",
                accountType: "Checking account"
            )
        )
    }
}
