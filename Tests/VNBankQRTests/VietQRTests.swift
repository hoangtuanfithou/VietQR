//
//  VietQRTests.swift
//  VietQRTests
//
//  Created by admin on 30/9/25.
//

import Testing
import XCTest
@testable import VNBankQR

final class VietQRTests: XCTestCase {

    // MARK: - Parse Tests

    func testParseValidVietQRString() {
        // Given: Valid VietQR string from the example
        let qrString = "00020101021238570010A00000072701270006970436011300110018008790208QRIBFTTA530370454061000005802VN62130809nhan tien6304D1EF"

        // When: Parsing the QR string
        let result = VNBankQR.shared.parseVietQR(qrString: qrString)
        
        // Then: Should successfully parse with correct values
        XCTAssertNotNil(result, "Parser should return a VietQR object")
        
        guard let vietQR = result else { return }
        
        XCTAssertEqual(vietQR.bankBin, "970436", "Bank BIN should be 970436")
        XCTAssertEqual(vietQR.accountNumber, "00110018008790", "Account number should be 00110018008790")
        XCTAssertEqual(vietQR.amount, "100000", "Amount should be 100000")
        XCTAssertEqual(vietQR.purpose, "nhan tien", "Description should be 'nhan tien'")
        XCTAssertEqual(vietQR.serviceCode, "QRIBFTTA", "Service code should be QRIBFTTA")
        XCTAssertEqual(vietQR.additionalData?.purpose, "nhan tien", "Purpose should be 'nhan tien'")
    }
    
    func testParseVietQRWithoutAmount() {
        // Given: VietQR string without amount
        let qrString = "00020101021238530010A00000072701230006970436011300110018008790208QRIBFTTA5303704582VN62130809nhan tien6304XXXX"

        // When: Parsing the QR string
        let result = VNBankQR.shared.parseVietQR(qrString: qrString)
        
        // Then: Should parse successfully with nil amount
        XCTAssertNotNil(result)
        XCTAssertNil(result?.amount, "Amount should be nil when not provided")
    }
    
    func testParseVietQRWithoutDescription() {
        // Given: VietQR string without description
        let qrString = "00020101021238530010A00000072701230006970436011300110018008790208QRIBFTTA530370454061000005802VN6304XXXX"
        
        // When: Parsing the QR string
        let result = VNBankQR.shared.parseVietQR(qrString: qrString)
        
        // Then: Should parse successfully with nil description
        XCTAssertNotNil(result)
        XCTAssertNil(result?.purpose, "Description should be nil when not provided")
    }
    
    func testParseInvalidFormat() {
        // Given: Invalid QR string
        let qrString = "invalid_qr_string"
        
        // When: Parsing the QR string
        let result = VNBankQR.shared.parseVietQR(qrString: qrString)
        
        // Then: Should return nil
        XCTAssertNil(result, "Parser should return nil for invalid format")
    }
    
    func testParseEmptyString() {
        // Given: Empty string
        let qrString = ""
        
        // When: Parsing the QR string
        let result = VNBankQR.shared.parseVietQR(qrString: qrString)
        
        // Then: Should return nil
        XCTAssertNil(result, "Parser should return nil for empty string")
    }
    
    func testParseMissingMerchantInfo() {
        // Given: QR string without merchant info (tag 38)
        let qrString = "00020101021253037045802VN6304XXXX"
        
        // When: Parsing the QR string
        let result = VNBankQR.shared.parseVietQR(qrString: qrString)
        
        // Then: Should return nil
        XCTAssertNil(result, "Parser should return nil when merchant info is missing")
    }
    
    // MARK: - Generate Tests
    
    func testGenerateVietQRString() {
        // Given: VietQR object
        let vietQR = VietQR(
            bankBin: "970436",
            accountNumber: "00110018008790",
            amount: "100000",
            purpose: "nhan tien"
        )
        
        // When: Generating QR string
        let qrString = VNBankQR.shared.generateVietQRString(from: vietQR)
        
        // Then: Should generate valid QR string
        XCTAssertFalse(qrString.isEmpty, "Generated QR string should not be empty")
        XCTAssertTrue(qrString.hasPrefix("000201"), "QR string should start with payload format indicator")
        XCTAssertTrue(qrString.contains("970436"), "QR string should contain bank BIN")
        XCTAssertTrue(qrString.contains("00110018008790"), "QR string should contain account number")
        XCTAssertTrue(qrString.hasSuffix("6304"), "QR string should end with CRC tag")
    }
    
    func testGenerateAndParseRoundTrip() {
        // Given: Original VietQR object
        let original = VietQR(
            bankBin: "970436",
            accountNumber: "00110018008790",
            amount: "100000",
            purpose: "test payment"
        )
        
        // When: Generate string and parse it back
        let qrString = VNBankQR.shared.generateVietQRString(from: original)
        let parsed = VNBankQR.shared.parseVietQR(qrString: qrString)
        
        // Then: Parsed object should match original
        XCTAssertNotNil(parsed)
        XCTAssertEqual(parsed?.bankBin, original.bankBin)
        XCTAssertEqual(parsed?.accountNumber, original.accountNumber)
        XCTAssertEqual(parsed?.amount, original.amount)
        XCTAssertEqual(parsed?.purpose, original.purpose)
    }
    
    func testGenerateWithoutOptionalFields() {
        // Given: VietQR with only required fields
        let vietQR = VietQR(
            bankBin: "970436",
            accountNumber: "123456789"
        )
        
        // When: Generating QR string
        let qrString = VNBankQR.shared.generateVietQRString(from: vietQR)
        
        // Then: Should generate valid QR string without optional fields
        XCTAssertFalse(qrString.isEmpty)
        XCTAssertFalse(qrString.contains("54"), "Should not contain amount tag when amount is nil")
    }
    
    // MARK: - Additional Data Tests
    
    func testParseAdditionalDataFields() {
        // Given: VietQR string with multiple additional data fields
        let qrString = "00020101021238570010A00000072701270006970436011300110018008790208QRIBFTTA530370454061000005802VN62410105bill1020212345678903store05ref1230809purpose16304XXXX"
        
        // When: Parsing the QR string
        let result = VNBankQR.shared.parseVietQR(qrString: qrString)
        
        // Then: Should parse all additional data fields
        XCTAssertNotNil(result?.additionalData)
        XCTAssertEqual(result?.additionalData?.billNumber, "bill1")
        XCTAssertEqual(result?.additionalData?.mobileNumber, "0123456789")
        XCTAssertEqual(result?.additionalData?.store, "store")
        XCTAssertEqual(result?.additionalData?.reference, "ref123")
        XCTAssertEqual(result?.additionalData?.purpose, "purpose1")
    }
    
    // MARK: - Bank Directory Tests
    
    func testBankDirectoryLookup() {
        // Given: Known bank BIN
        let bankBin = "970436"
        
        // When: Looking up bank info
        let bankInfo = VietQRBankDirectory.shared.getBank(bin: bankBin)
        
        // Then: Should return correct bank info
        XCTAssertNotNil(bankInfo)
        XCTAssertEqual(bankInfo?.shortName, "Vietcombank")
        XCTAssertEqual(bankInfo?.bin, "970436")
    }
    
    func testBankDirectoryUnknownBank() {
        // Given: Unknown bank BIN
        let bankBin = "999999"
        
        // When: Looking up bank info
        let bankInfo = VietQRBankDirectory.shared.getBank(bin: bankBin)
        
        // Then: Should return nil
        XCTAssertNil(bankInfo)
    }
    
    // MARK: - Display Info Tests
    
    func testDisplayInfo() {
        // Given: VietQR with all fields
        let vietQR = VietQR(
            bankBin: "970436",
            accountNumber: "00110018008790",
            amount: "100000",
            purpose: "test"
        )
        
        // When: Getting display info
        let displayInfo = vietQR.displayInfo
        
        // Then: Should contain all information
        XCTAssertTrue(displayInfo.contains("970436"))
        XCTAssertTrue(displayInfo.contains("00110018008790"))
        XCTAssertTrue(displayInfo.contains("100,000"))
        XCTAssertTrue(displayInfo.contains("test"))
    }
    
    // MARK: - Edge Cases
    
    func testParseLongAccountNumber() {
        // Given: VietQR with long account number
        let vietQR = VietQR(
            bankBin: "970436",
            accountNumber: "12345678901234567890"
        )
        
        // When: Generate and parse
        let qrString = VNBankQR.shared.generateVietQRString(from: vietQR)
        let parsed = VNBankQR.shared.parseVietQR(qrString: qrString)
        
        // Then: Should handle long account numbers
        XCTAssertEqual(parsed?.accountNumber, "12345678901234567890")
    }
    
    func testParseSpecialCharactersInDescription() {
        // Given: VietQR with special characters
        let vietQR = VietQR(
            bankBin: "970436",
            accountNumber: "123456",
            purpose: "Thanh toán hóa đơn"
        )
        
        // When: Generate and parse
        let qrString = VNBankQR.shared.generateVietQRString(from: vietQR)
        let parsed = VNBankQR.shared.parseVietQR(qrString: qrString)
        
        // Then: Should preserve special characters
        XCTAssertEqual(parsed?.purpose, "Thanh toán hóa đơn")
    }
    
    func testParseZeroAmount() {
        // Given: VietQR with zero amount
        let vietQR = VietQR(
            bankBin: "970436",
            accountNumber: "123456",
            amount: "0"
        )
        
        // When: Generate and parse
        let qrString = VNBankQR.shared.generateVietQRString(from: vietQR)
        let parsed = VNBankQR.shared.parseVietQR(qrString: qrString)
        
        // Then: Should handle zero amount
        XCTAssertEqual(parsed?.amount, "0")
    }
}
