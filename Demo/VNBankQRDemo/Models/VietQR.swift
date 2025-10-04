//
//  VietQR.swift
//  VietQR Demo App
//
//  This file imports VNBankQR package and provides backward compatibility
//

import Foundation
import UIKit

// Re-export VNBankQR for easy access
@_exported import VNBankQR

// MARK: - Legacy Compatibility Layer

/// Legacy VietQRService for backward compatibility with old code
/// This delegates to the new VNBankQR package
public typealias VietQRService = VNBankQRLegacyService

public class VNBankQRLegacyService {
    public static let shared = VNBankQRLegacyService()
    private init() {}

    public func parse(from qrString: String) -> VietQR? {
        return VNBankQR.shared.parseVietQR(qrString: qrString)
    }

    public func generate(from vietQR: VietQR) -> String {
        return VNBankQR.shared.generateVietQRString(from: vietQR)
    }

    public func generateQRImage(from vietQR: VietQR, size: CGSize = CGSize(width: 300, height: 300)) -> UIImage? {
        return VNBankQR.shared.generateVietQRImage(from: vietQR, size: size)
    }

    public func parse(from image: UIImage) -> VietQR? {
        return VNBankQR.shared.parseVietQR(image: image)
    }
}

/// Legacy BankDirectory
public typealias BankDirectory = VietQRBankDirectory
