//
//  BankQRScannerDelegate.swift
//  VNBankQR
//
//  Bank QR scanner delegate protocol
//

import Foundation

/// Delegate for Bank QR code scanning
public protocol BankQRScannerDelegate: AnyObject {
    /// Called when a bank QR code is successfully scanned and parsed
    /// - Parameter qrCode: Parsed QR code object (VietQR, MoMo, ZaloPay, etc.)
    func didScanBankQR(_ qrCode: any BankQRProtocol)

    /// Called when scanning fails
    /// - Parameter error: Error that occurred
    func didFailScanning(error: BankQRError)
}

/// Specific delegate for VietQR scanning (for backward compatibility)
public protocol VietQRScannerDelegate: AnyObject {
    func didScanVietQR(_ vietQR: VietQR)
    func didFailScanning(error: Error)
}
