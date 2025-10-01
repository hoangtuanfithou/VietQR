////
////  public.swift
////  VietQR
////
////  Created by admin on 30/9/25.
////
//
//// MARK: - VietQR Library Core
//
//import UIKit
//import AVFoundation
//import CoreImage
//
///// Main VietQR library class
//public class VietQRManager {
//    public static let shared = VietQRManager()
//    private init() {}
//
//    // MARK: - QR Code Generation
//
//    /// Generate UIImage from VietQR object
//    public func generateQRImage(from vietQR: VietQR, size: CGSize = CGSize(width: 200, height: 200)) -> UIImage? {
//        let qrString = vietQR.toQRString()
//
//        guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
//        guard let data = qrString.data(using: .utf8) else { return nil }
//
//        filter.setValue(data, forKey: "inputMessage")
//        filter.setValue("H", forKey: "inputCorrectionLevel")
//
//        guard let ciImage = filter.outputImage else { return nil }
//
//        let scaleX = size.width / ciImage.extent.width
//        let scaleY = size.height / ciImage.extent.height
//        let scaledImage = ciImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
//
//        let context = CIContext()
//        guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else { return nil }
//
//        return UIImage(cgImage: cgImage)
//    }
//
//    // MARK: - QR Code Scanning
//
//    /// Parse VietQR from UIImage
//    public func parseVietQR(from image: UIImage) -> Result<VietQR, VietQRError> {
//        guard let ciImage = CIImage(image: image) else {
//            return .failure(.invalidQRCode)
//        }
//
//        let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
//        let features = detector?.features(in: ciImage) ?? []
//
//        for feature in features {
//            if let qrFeature = feature as? CIQRCodeFeature,
//               let messageString = qrFeature.messageString,
//               let vietQR = VietQR.fromQRString(messageString) {
//                return .success(vietQR)
//            }
//        }
//
//        return .failure(.parsingFailed)
//    }
//}
