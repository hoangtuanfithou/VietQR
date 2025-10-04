//
//  BankQRFactory.swift
//  VNBankQR
//
//  Factory for auto-detecting and parsing different Vietnamese bank QR code types
//

import Foundation
import UIKit

/// Factory class for detecting and parsing various Vietnamese bank QR code types
public class BankQRFactory: BankQRFactoryProtocol {
    public static let shared = BankQRFactory()
    private init() {}

    // Register parsers here - add new QR code types as needed
    private lazy var parsers: [any BankQRParser] = [
        VietQRParser.shared,
        // Add future Vietnamese QR parsers here:
        // MoMoQRParser.shared,
        // ZaloPayQRParser.shared,
        // VNPayQRParser.shared,
    ]

    // MARK: - BankQRFactory Protocol

    public func detectParser(for qrString: String) -> (any BankQRParser)? {
        for parser in parsers {
            if parser.canParse(qrString) {
                return parser
            }
        }
        return nil
    }

    public func parseBankQR(from qrString: String) -> (any BankQRProtocol)? {
        guard let parser = detectParser(for: qrString) else {
            return nil
        }

        // Use type erasure to handle different parser types
        if let vietQRParser = parser as? VietQRParser {
            return vietQRParser.parse(from: qrString)
        }
        // Add future Vietnamese QR types here:
        // if let momoQRParser = parser as? MoMoQRParser {
        //     return momoQRParser.parse(from: qrString)
        // }
        // if let zaloPayQRParser = parser as? ZaloPayQRParser {
        //     return zaloPayQRParser.parse(from: qrString)
        // }

        return nil
    }

    /// Parse bank QR code from image with auto-detection
    /// - Parameter image: UIImage containing QR code
    /// - Returns: Parsed QR code or nil
    public func parseBankQR(from image: UIImage) -> (any BankQRProtocol)? {
        guard let qrString = QRCodeDetector.shared.detectFirstQRCode(in: image) else {
            return nil
        }
        return parseBankQR(from: qrString)
    }

    /// Register a custom parser
    /// - Parameter parser: Custom QR code parser
    public func registerParser(_ parser: any BankQRParser) {
        parsers.append(parser)
    }
}

// MARK: - Convenience Methods

extension BankQRFactory {
    /// Parse as VietQR specifically
    public func parseVietQR(from qrString: String) -> VietQR? {
        return VietQRParser.shared.parse(from: qrString)
    }

    /// Parse VietQR from image
    public func parseVietQR(from image: UIImage) -> VietQR? {
        return VietQRParser.shared.parse(from: image)
    }

    /// Generate QR image from any bank QR code type
    public func generateImage(from qrCode: any BankQRProtocol, size: CGSize = CGSize(width: 300, height: 300)) -> UIImage? {
        let qrString = qrCode.toQRString()
        return QRCodeImageGenerator.shared.generateImage(from: qrString, size: size)
    }
}
