//
//  VietQR.swift
//  VietQR
//
//  Created by admin on 30/9/25.
//

/// VietQR standard data structure
public struct VietQR {
    public let bankBin: String
    public let accountNumber: String
    public let template: String
    public let amount: String?
    public let description: String?
    public let accountName: String?

    public init(
        bankBin: String,
        accountNumber: String,
        template: String = "compact2",
        amount: String? = nil,
        description: String? = nil,
        accountName: String? = nil
    ) {
        self.bankBin = bankBin
        self.accountNumber = accountNumber
        self.template = template
        self.amount = amount
        self.description = description
        self.accountName = accountName
    }
}
