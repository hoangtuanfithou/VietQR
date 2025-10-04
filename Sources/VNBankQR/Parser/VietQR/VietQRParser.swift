//
//  VietQRParser.swift
//  VietQR
//
//  VietQR parsing logic with TLV and CRC utilities
//

import Foundation
import UIKit

/// Parser for VietQR following NAPAS specification
public class VietQRParser: BankQRParser {
    public typealias QRCodeType = VietQR

    public static let shared = VietQRParser()
    private init() {}

    private let GUID = "A000000727"  // NAPAS AID

    // MARK: - BankQRParser Protocol

    public func canParse(_ qrString: String) -> Bool {
        let fields = parseTLV(qrString)
        // Check for VietQR format indicators
        guard fields["00"] == "01",  // Payload format indicator
              let merchantInfo = fields["38"] else {
            return false
        }
        let merchantFields = parseTLV(merchantInfo)
        return merchantFields["00"] == GUID  // NAPAS GUID
    }

    public func parse(from qrString: String) -> VietQR? {
        let fields = parseTLV(qrString)

        // Validate payload format indicator (Tag 00 = "01")
        guard fields["00"] == "01" else { return nil }

        // Parse merchant account information (Tag 38 for VietQR)
        guard let merchantInfo = fields["38"] else { return nil }
        let merchantFields = parseTLV(merchantInfo)

        // Validate GUID (Tag 00 = "A000000727")
        guard merchantFields["00"] == GUID else { return nil }

        // Parse BNB structure (Tag 01)
        guard let bnbInfo = merchantFields["01"] else { return nil }
        let bnbFields = parseTLV(bnbInfo)

        // Extract Bank BIN (Tag 00) and Account Number (Tag 01)
        guard let bankBin = bnbFields["00"],
              let accountNumber = bnbFields["01"] else {
            return nil
        }

        // Service code (Tag 02)
        let serviceCode = merchantFields["02"] ?? "QRIBFTTA"

        // Transaction amount (Tag 54)
        let amount = fields["54"]

        // Merchant name / Account name (Tag 59)
        let accountName = fields["59"]

        // Parse additional data (Tag 62)
        var purpose: String? = nil
        var additionalData: VietQR.AdditionalData? = nil

        if let additionalInfo = fields["62"] {
            let additionalFields = parseTLV(additionalInfo)

            var data = VietQR.AdditionalData()
            data.billNumber = additionalFields["01"]
            data.mobileNumber = additionalFields["02"]
            data.store = additionalFields["03"]
            data.loyaltyNumber = additionalFields["04"]
            data.reference = additionalFields["05"]
            data.customerLabel = additionalFields["06"]
            data.terminal = additionalFields["07"]
            data.purpose = additionalFields["08"]

            additionalData = data
            purpose = data.purpose
        }

        var vietQR = VietQR(
            bankBin: bankBin,
            accountNumber: accountNumber,
            accountName: accountName,
            amount: amount,
            purpose: purpose
        )

        vietQR.serviceCode = serviceCode
        vietQR.additionalData = additionalData

        return vietQR
    }

    public func parse(from image: UIImage) -> VietQR? {
        guard let qrString = QRCodeDetector.shared.detectFirstQRCode(in: image) else {
            return nil
        }
        return parse(from: qrString)
    }

    // MARK: - TLV Parsing

    /// Parse TLV (Tag-Length-Value) format string
    /// - Parameter data: TLV formatted string
    /// - Returns: Dictionary of tag-value pairs
    public func parseTLV(_ data: String) -> [String: String] {
        var result: [String: String] = [:]
        var index = data.startIndex

        while index < data.endIndex {
            guard data.distance(from: index, to: data.endIndex) >= 4 else { break }

            let tagEnd = data.index(index, offsetBy: 2)
            let tag = String(data[index..<tagEnd])

            let lengthEnd = data.index(tagEnd, offsetBy: 2)
            let lengthStr = String(data[tagEnd..<lengthEnd])
            guard let length = Int(lengthStr) else { break }

            guard data.distance(from: lengthEnd, to: data.endIndex) >= length else { break }

            let valueEnd = data.index(lengthEnd, offsetBy: length)
            let value = String(data[lengthEnd..<valueEnd])

            result[tag] = value
            index = valueEnd
        }

        return result
    }

    /// Build TLV formatted string
    /// - Parameters:
    ///   - tag: 2-character tag
    ///   - value: Value string
    /// - Returns: TLV formatted string (Tag + Length + Value)
    public func buildTLV(_ tag: String, _ value: String) -> String {
        let length = String(format: "%02d", value.count)
        return "\(tag)\(length)\(value)"
    }

    // MARK: - CRC Calculation

    /// Calculate CRC-16/CCITT-FALSE checksum
    /// - Parameter data: Data string including "6304" but excluding CRC value
    /// - Returns: 4-character hex CRC value
    public func calculateCRC(_ data: String) -> String {
        let bytes = Array(data.utf8)
        var crc: UInt16 = 0xFFFF

        for byte in bytes {
            crc ^= UInt16(byte) << 8
            for _ in 0..<8 {
                if (crc & 0x8000) != 0 {
                    crc = (crc << 1) ^ 0x1021
                } else {
                    crc = crc << 1
                }
            }
        }

        return String(format: "%04X", crc & 0xFFFF)
    }
}
