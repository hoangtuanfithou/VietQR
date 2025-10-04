//
//  BankQRProtocol.swift
//  VNBankQR
//
//  Core protocols for Vietnamese bank QR code system
//

import Foundation
import UIKit

// MARK: - Base Bank QR Protocol

/// Base protocol that all Vietnamese bank QR code types must conform to
public protocol BankQRProtocol {
    /// The type identifier for this QR code (e.g., "VietQR", "MoMoQR", "ZaloPayQR")
    static var qrCodeType: String { get }

    /// Convert this QR code data to a string format for QR generation
    func toQRString() -> String

    /// Human-readable display information
    var displayInfo: String { get }
}

// MARK: - Parser Protocol

/// Protocol for parsing bank QR code strings into specific QR code types
public protocol BankQRParser {
    associatedtype QRCodeType: BankQRProtocol

    /// Parse a QR code string into the specific QR code type
    /// - Parameter qrString: Raw QR code string
    /// - Returns: Parsed QR code object or nil if parsing fails
    func parse(from qrString: String) -> QRCodeType?

    /// Parse a QR code from an image
    /// - Parameter image: UIImage containing QR code
    /// - Returns: Parsed QR code object or nil if parsing fails
    func parse(from image: UIImage) -> QRCodeType?

    /// Check if this parser can handle the given QR string
    /// - Parameter qrString: Raw QR code string
    /// - Returns: True if this parser can handle the format
    func canParse(_ qrString: String) -> Bool
}

// MARK: - Generator Protocol

/// Protocol for generating bank QR code strings and images
public protocol BankQRGenerator {
    associatedtype QRCodeType: BankQRProtocol

    /// Generate QR code string from QR code object
    /// - Parameter qrCode: QR code data object
    /// - Returns: String representation for QR code
    func generateString(from qrCode: QRCodeType) -> String

    /// Generate QR code image from QR code object
    /// - Parameters:
    ///   - qrCode: QR code data object
    ///   - size: Desired image size
    /// - Returns: UIImage or nil if generation fails
    func generateImage(from qrCode: QRCodeType, size: CGSize) -> UIImage?
}

// MARK: - Bank QR Factory Protocol

/// Factory protocol for auto-detecting and creating appropriate bank QR code parsers
public protocol BankQRFactoryProtocol {
    /// Detect bank QR code type from string and return appropriate parser
    /// - Parameter qrString: Raw QR code string
    /// - Returns: Parser that can handle this QR code type, or nil if unknown
    func detectParser(for qrString: String) -> (any BankQRParser)?

    /// Parse bank QR code string using auto-detection
    /// - Parameter qrString: Raw QR code string
    /// - Returns: Parsed QR code or nil if no parser can handle it
    func parseBankQR(from qrString: String) -> (any BankQRProtocol)?
}
