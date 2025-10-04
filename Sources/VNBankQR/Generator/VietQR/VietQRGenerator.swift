//
//  VietQRGenerator.swift
//  VietQR
//
//  VietQR string generation following NAPAS specification
//

import Foundation
import UIKit

/// Generator for VietQR strings and images
public class VietQRGenerator: BankQRGenerator {
    public typealias QRCodeType = VietQR

    public static let shared = VietQRGenerator()
    private init() {}

    private let GUID = "A000000727"  // NAPAS AID
    private let parser = VietQRParser.shared

    // MARK: - BankQRGenerator Protocol

    public func generateString(from qrCode: VietQR) -> String {
        return generate(from: qrCode)
    }

    public func generateImage(from qrCode: VietQR, size: CGSize = CGSize(width: 300, height: 300)) -> UIImage? {
        let qrString = generate(from: qrCode)
        return QRCodeImageGenerator.shared.generateImage(from: qrString, size: size)
    }

    // MARK: - String Generation

    /// Generate EMV QCO string from VietQR object
    /// - Parameter vietQR: VietQR object
    /// - Returns: EMV format string compliant with NAPAS VietQR spec
    public func generate(from vietQR: VietQR) -> String {
        var result = ""

        // 00: Payload Format Indicator
        result += parser.buildTLV("00", "01")

        // 01: Point of Initiation Method (11 = static, 12 = dynamic)
        let isStatic = vietQR.amount == nil || vietQR.amount?.isEmpty == true
        result += parser.buildTLV("01", isStatic ? "11" : "12")

        // 38: Merchant Account Information (VietQR)
        // Structure: Tag 38 contains nested TLV
        //   - Tag 00: GUID (A000000727)
        //   - Tag 01: BNB structure
        //     - Tag 00: Bank BIN (6 digits)
        //     - Tag 01: Account Number
        //   - Tag 02: Service Code (QRIBFTTA or QRIBFTTC)

        var bnbInfo = ""
        bnbInfo += parser.buildTLV("00", vietQR.bankBin)
        bnbInfo += parser.buildTLV("01", vietQR.accountNumber)

        var merchantInfo = ""
        merchantInfo += parser.buildTLV("00", GUID)
        merchantInfo += parser.buildTLV("01", bnbInfo)
        merchantInfo += parser.buildTLV("02", vietQR.serviceCode)

        result += parser.buildTLV("38", merchantInfo)

        // 53: Transaction Currency (704 = VND)
        result += parser.buildTLV("53", "704")

        // 54: Transaction Amount (optional)
        if let amount = vietQR.amount, !amount.isEmpty {
            result += parser.buildTLV("54", amount)
        }

        // 58: Country Code
        result += parser.buildTLV("58", "VN")

        // 59: Merchant Name (Account Name) - optional
        if let accountName = vietQR.accountName, !accountName.isEmpty {
            result += parser.buildTLV("59", accountName)
        }

        // 62: Additional Data (optional)
        if let additional = vietQR.additionalData {
            var additionalStr = ""

            if let billNumber = additional.billNumber, !billNumber.isEmpty {
                additionalStr += parser.buildTLV("01", billNumber)
            }
            if let mobile = additional.mobileNumber, !mobile.isEmpty {
                additionalStr += parser.buildTLV("02", mobile)
            }
            if let store = additional.store, !store.isEmpty {
                additionalStr += parser.buildTLV("03", store)
            }
            if let loyalty = additional.loyaltyNumber, !loyalty.isEmpty {
                additionalStr += parser.buildTLV("04", loyalty)
            }
            if let reference = additional.reference, !reference.isEmpty {
                additionalStr += parser.buildTLV("05", reference)
            }
            if let customer = additional.customerLabel, !customer.isEmpty {
                additionalStr += parser.buildTLV("06", customer)
            }
            if let terminal = additional.terminal, !terminal.isEmpty {
                additionalStr += parser.buildTLV("07", terminal)
            }
            if let purpose = additional.purpose, !purpose.isEmpty {
                additionalStr += parser.buildTLV("08", purpose)
            }

            if !additionalStr.isEmpty {
                result += parser.buildTLV("62", additionalStr)
            }
        } else if let purpose = vietQR.purpose, !purpose.isEmpty {
            // If no additionalData but purpose exists, create it
            let additionalStr = parser.buildTLV("08", purpose)
            result += parser.buildTLV("62", additionalStr)
        }

        // 63: CRC (always last) - ISO/IEC 13239 using polynomial '1021' (hex) and initial value 'FFFF' (hex)
        result += "6304"
        let crc = parser.calculateCRC(result)
        result += crc

        return result
    }
}
