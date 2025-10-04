//
//  QRCodeImageGenerator.swift
//  VietQR
//
//  Generic QR code image generation utilities
//

import Foundation
import UIKit
import CoreImage

/// Generic QR code image generator that works with any QR code string
public class QRCodeImageGenerator {
    public static let shared = QRCodeImageGenerator()
    private init() {}

    /// Generate QR code image from any string
    /// - Parameters:
    ///   - qrString: String to encode in QR code
    ///   - size: Desired image size (default: 300x300)
    ///   - correctionLevel: Error correction level (L, M, Q, H)
    /// - Returns: UIImage or nil if generation fails
    public func generateImage(from qrString: String,
                            size: CGSize = CGSize(width: 300, height: 300),
                            correctionLevel: QRCorrectionLevel = .high) -> UIImage? {
        guard let data = qrString.data(using: .utf8),
              let filter = CIFilter(name: "CIQRCodeGenerator") else {
            return nil
        }

        filter.setValue(data, forKey: "inputMessage")
        filter.setValue(correctionLevel.rawValue, forKey: "inputCorrectionLevel")

        guard let ciImage = filter.outputImage else { return nil }

        let scaleX = size.width / ciImage.extent.width
        let scaleY = size.height / ciImage.extent.height
        let transform = CGAffineTransform(scaleX: scaleX, y: scaleY)
        let scaledImage = ciImage.transformed(by: transform)

        let context = CIContext()
        guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else {
            return nil
        }

        return UIImage(cgImage: cgImage)
    }

    /// Generate QR code image from any BankQRProtocol object
    /// - Parameters:
    ///   - qrCode: QR code object
    ///   - size: Desired image size
    ///   - correctionLevel: Error correction level
    /// - Returns: UIImage or nil if generation fails
    public func generateImage(from qrCode: any BankQRProtocol,
                            size: CGSize = CGSize(width: 300, height: 300),
                            correctionLevel: QRCorrectionLevel = .high) -> UIImage? {
        let qrString = qrCode.toQRString()
        return generateImage(from: qrString, size: size, correctionLevel: correctionLevel)
    }
}

// MARK: - QR Correction Level

public enum QRCorrectionLevel: String {
    case low = "L"      // 7% error correction
    case medium = "M"   // 15% error correction
    case quartile = "Q" // 25% error correction
    case high = "H"     // 30% error correction
}
