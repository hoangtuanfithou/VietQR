//
//  VietQRModel.swift
//  VNBankQR
//
//  VietQR data model following EMV QCO specification and NAPAS VietQR standard
//  Part 2 & 3: Parser & Generator support for VietQR
//

import Foundation

// MARK: - VietQR Data Model

/// VietQR data model following EMV QCO specification and NAPAS VietQR standard v1.0 (September 2021)
/// Supports 40+ Vietnamese banks
public struct VietQR: BankQRProtocol {
    public static let qrCodeType: String = "VietQR"

    // Merchant Account Information (Tag 38)
    public var bankBin: String              // Acquirer/BNB ID (6 digits)
    public var accountNumber: String        // Consumer ID / Account Number
    public var accountName: String?         // Merchant Name (Tag 59)
    public var amount: String?              // Transaction Amount (Tag 54)
    public var purpose: String?             // Purpose of Transaction (Tag 62-08)

    // Service codes
    public var serviceCode: String = "QRIBFTTA"  // QRIBFTTA (account) or QRIBFTTC (card)

    // Additional data from Tag 62
    public var additionalData: AdditionalData?

    public struct AdditionalData {
        public var billNumber: String?          // Tag 62-01
        public var mobileNumber: String?        // Tag 62-02
        public var store: String?               // Tag 62-03
        public var loyaltyNumber: String?       // Tag 62-04
        public var reference: String?           // Tag 62-05
        public var customerLabel: String?       // Tag 62-06
        public var terminal: String?            // Tag 62-07
        public var purpose: String?             // Tag 62-08

        public init(billNumber: String? = nil, mobileNumber: String? = nil, store: String? = nil,
                    loyaltyNumber: String? = nil, reference: String? = nil, customerLabel: String? = nil,
                    terminal: String? = nil, purpose: String? = nil) {
            self.billNumber = billNumber
            self.mobileNumber = mobileNumber
            self.store = store
            self.loyaltyNumber = loyaltyNumber
            self.reference = reference
            self.customerLabel = customerLabel
            self.terminal = terminal
            self.purpose = purpose
        }
    }

    public init(bankBin: String, accountNumber: String, accountName: String? = nil,
                amount: String? = nil, purpose: String? = nil) {
        self.bankBin = bankBin
        self.accountNumber = accountNumber
        self.accountName = accountName
        self.amount = amount
        self.purpose = purpose

        if let purpose = purpose {
            self.additionalData = AdditionalData(purpose: purpose)
        }
    }

    // MARK: - BankQRProtocol Conformance

    public func toQRString() -> String {
        return VietQRGenerator.shared.generate(from: self)
    }

    public var displayInfo: String {
        var info = """
        Bank BIN: \(bankBin)
        Account: \(accountNumber)
        """

        if let accountName = accountName {
            info += "\nAccount Name: \(accountName)"
        }

        if let amount = amount {
            info += "\nAmount: \(formatAmount(amount)) VND"
        }

        if let purpose = purpose {
            info += "\nPurpose: \(purpose)"
        }

        if let ref = additionalData?.reference {
            info += "\nReference: \(ref)"
        }

        return info
    }

    private func formatAmount(_ amount: String) -> String {
        guard let value = Int(amount) else { return amount }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        return formatter.string(from: NSNumber(value: value)) ?? amount
    }
}
