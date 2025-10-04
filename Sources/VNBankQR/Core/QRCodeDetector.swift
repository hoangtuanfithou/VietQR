//
//  QRCodeDetector.swift
//  VietQR
//
//  Generic QR code detection from images
//

import Foundation
import UIKit
import CoreImage

/// Utility class for detecting and extracting QR code strings from images
public class QRCodeDetector {
    public static let shared = QRCodeDetector()
    private init() {}

    /// Detect and extract QR code strings from an image
    /// - Parameter image: UIImage containing QR code
    /// - Returns: Array of detected QR code strings (can be multiple codes in one image)
    public func detectQRCodes(in image: UIImage) -> [String] {
        guard let ciImage = CIImage(image: image),
              let detector = CIDetector(ofType: CIDetectorTypeQRCode,
                                       context: nil,
                                       options: [CIDetectorAccuracy: CIDetectorAccuracyHigh]) else {
            return []
        }

        let features = detector.features(in: ciImage)
        var qrStrings: [String] = []

        for feature in features {
            if let qrFeature = feature as? CIQRCodeFeature,
               let messageString = qrFeature.messageString {
                qrStrings.append(messageString)
            }
        }

        return qrStrings
    }

    /// Detect first QR code string from an image
    /// - Parameter image: UIImage containing QR code
    /// - Returns: First detected QR code string or nil
    public func detectFirstQRCode(in image: UIImage) -> String? {
        return detectQRCodes(in: image).first
    }
}
