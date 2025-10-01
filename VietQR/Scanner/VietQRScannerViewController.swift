////
////  VietQRScannerViewController.swift
////  VietQR
////
////  Created by admin on 30/9/25.
////
//
//import UIKit
//import AVFoundation
//
//public class VietQRScannerViewController2: UIViewController {
//    public weak var delegate: VietQRScannerDelegate?
//
//    private var captureSession: AVCaptureSession?
//    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
//    private let qrCodeFrameView = UIView()
//
//    public override func viewDidLoad() {
//        super.viewDidLoad()
//        setupCamera()
//        setupUI()
//    }
//
//    private func setupCamera() {
//        guard let device = AVCaptureDevice.default(for: .video) else {
//            delegate?.didFailWithError(.cameraNotAvailable)
//            return
//        }
//
//        do {
//            let input = try AVCaptureDeviceInput(device: device)
//            let captureSession = AVCaptureSession()
//            captureSession.addInput(input)
//
//            let captureMetadataOutput = AVCaptureMetadataOutput()
//            captureSession.addOutput(captureMetadataOutput)
//
//            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
//            captureMetadataOutput.metadataObjectTypes = [.qr]
//
//            self.captureSession = captureSession
//
//        } catch {
//            delegate?.didFailWithError(.cameraNotAvailable)
//        }
//    }
//
//    private func setupUI() {
//        guard let captureSession = captureSession else { return }
//
//        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
//        videoPreviewLayer?.videoGravity = .resizeAspectFill
//        videoPreviewLayer?.frame = view.layer.bounds
//        view.layer.addSublayer(videoPreviewLayer!)
//
//        // QR Frame indicator
//        qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
//        qrCodeFrameView.layer.borderWidth = 2
//        view.addSubview(qrCodeFrameView)
//
//        // Navigation setup
//        navigationItem.rightBarButtonItem = UIBarButtonItem(
//            title: "Cancel",
//            style: .plain,
//            target: self,
//            action: #selector(cancelTapped)
//        )
//
//        DispatchQueue.global(qos: .userInitiated).async {
//            captureSession.startRunning()
//        }
//    }
//
//    @objc private func cancelTapped() {
//        captureSession?.stopRunning()
//        dismiss(animated: true)
//    }
//
//    public override func viewWillLayoutSubviews() {
//        super.viewWillLayoutSubviews()
//        videoPreviewLayer?.frame = view.bounds
//    }
//}
//
//extension VietQRScannerViewController2: AVCaptureMetadataOutputObjectsDelegate {
//    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
//
//        if metadataObjects.isEmpty {
//            qrCodeFrameView.frame = CGRect.zero
//            return
//        }
//
//        if let metadataObj = metadataObjects.first,
//           let qrCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj),
//           let readableObject = metadataObj as? AVMetadataMachineReadableCodeObject,
//           let stringValue = readableObject.stringValue {
//
//            qrCodeFrameView.frame = qrCodeObject.bounds
//
//            if let vietQR = VietQR.fromQRString(stringValue) {
//                captureSession?.stopRunning()
//                delegate?.didScanVietQR(vietQR)
//            }
//        }
//    }
//}
