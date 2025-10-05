//
//  VNBankQR.swift
//  VNBankQR
//
//  Main public API for VNBankQR package
//  Vietnamese Bank QR Code Scanner, Parser & Generator
//

import Foundation
import UIKit

// MARK: - VNBankQR Main API

/// Main entry point for VNBankQR library
/// Supports Vietnamese bank QR codes: VietQR, MoMo, ZaloPay, VNPay
public final class VNBankQR {
    public static let shared = VNBankQR()
    private init() {}

    // MARK: - Part 1: Scanner

    /// Create a bank QR scanner view controller
    /// Supports all Vietnamese bank QR codes
    /// - Parameters:
    ///   - delegate: Scanner delegate to receive scan results
    ///   - configuration: Optional scanner configuration (overlay, scan area). Default configuration will be used if nil
    public func didScanBankQR(
        delegate: BankQRScannerDelegate,
        configuration: ScannerConfiguration? = nil
    ) -> BankQRScannerViewController {
        let scanner = BankQRScannerViewController()
        scanner.delegate = delegate
        if let config = configuration {
            scanner.configuration = config
        }
        return scanner
    }

    // MARK: - Part 2: Parser

    /// Parse any Vietnamese bank QR code from string
    /// Auto-detects: VietQR, MoMo, ZaloPay, VNPay
    public func parse(qrString: String) -> (any BankQRProtocol)? {
        return BankQRFactory.shared.parseBankQR(from: qrString)
    }

    /// Parse any Vietnamese bank QR code from image
    public func parse(image: UIImage) -> (any BankQRProtocol)? {
        return BankQRFactory.shared.parseBankQR(from: image)
    }

    /// Parse specifically VietQR from string
    public func parseVietQR(qrString: String) -> VietQR? {
        return VietQRParser.shared.parse(from: qrString)
    }

    /// Parse specifically VietQR from image
    public func parseVietQR(image: UIImage) -> VietQR? {
        return VietQRParser.shared.parse(from: image)
    }

    // MARK: - Part 3: Generator

    /// Generate QR code image from any bank QR object
    public func generateImage(from qrCode: any BankQRProtocol, size: CGSize = CGSize(width: 300, height: 300)) -> UIImage? {
        return BankQRFactory.shared.generateImage(from: qrCode, size: size)
    }

    /// Generate VietQR code image
    public func generateVietQRImage(from vietQR: VietQR, size: CGSize = CGSize(width: 300, height: 300)) -> UIImage? {
        return VietQRGenerator.shared.generateImage(from: vietQR, size: size)
    }

    /// Generate VietQR string
    public func generateVietQRString(from vietQR: VietQR) -> String {
        return VietQRGenerator.shared.generate(from: vietQR)
    }
}

// MARK: - Convenience Extensions

public extension VietQR {
    /// Quick generate QR image
    func generateQRImage(size: CGSize = CGSize(width: 300, height: 300)) -> UIImage? {
        return VNBankQR.shared.generateVietQRImage(from: self, size: size)
    }
}
