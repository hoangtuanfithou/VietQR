//
//  BankQRError.swift
//  VNBankQR
//
//  Bank QR code errors
//

import Foundation

/// Errors for bank QR code operations
public enum BankQRError: Error {
    case invalidQRCode
    case cameraNotAvailable
    case generationFailed
    case parsingFailed
    case unsupportedQRCodeType
    case invalidFormat
}

extension BankQRError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidQRCode:
            return "Invalid QR code format"
        case .cameraNotAvailable:
            return "Camera not available"
        case .generationFailed:
            return "Failed to generate QR code"
        case .parsingFailed:
            return "Failed to parse QR code data"
        case .unsupportedQRCodeType:
            return "Unsupported QR code type"
        case .invalidFormat:
            return "Invalid QR code format"
        }
    }
}
