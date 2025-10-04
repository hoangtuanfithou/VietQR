//
//  BankQRScannerViewController.swift
//  VNBankQR
//
//  Universal Bank QR scanner - supports all Vietnamese bank QR codes
//  Part 1: Scanner Component
//

import UIKit
import AVFoundation

/// Universal Bank QR scanner that can detect and parse any registered Vietnamese bank QR code
public class BankQRScannerViewController: UIViewController {
    public weak var delegate: BankQRScannerDelegate?

    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var hasScanned = false

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
        setupUI()
    }

    private func setupCamera() {
        guard let device = AVCaptureDevice.default(for: .video) else {
            delegate?.didFailScanning(error: .cameraNotAvailable)
            return
        }

        do {
            let input = try AVCaptureDeviceInput(device: device)
            let session = AVCaptureSession()
            session.addInput(input)

            let output = AVCaptureMetadataOutput()
            session.addOutput(output)
            output.setMetadataObjectsDelegate(self, queue: .main)
            output.metadataObjectTypes = [.qr]

            self.captureSession = session
        } catch {
            delegate?.didFailScanning(error: .cameraNotAvailable)
        }
    }

    private func setupUI() {
        guard let session = captureSession else { return }

        view.backgroundColor = .black
        title = "Scan QR Code"

        let preview = AVCaptureVideoPreviewLayer(session: session)
        preview.frame = view.bounds
        preview.videoGravity = .resizeAspectFill
        view.layer.addSublayer(preview)
        previewLayer = preview

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelTapped)
        )

        session.startRunning()
    }

    @objc private func cancelTapped() {
        captureSession?.stopRunning()
        dismiss(animated: true)
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
    }
}

extension BankQRScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    public func metadataOutput(_ output: AVCaptureMetadataOutput,
                              didOutput metadataObjects: [AVMetadataObject],
                              from connection: AVCaptureConnection) {
        guard !hasScanned,
              let metadata = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let qrString = metadata.stringValue else {
            return
        }

        // Use factory to auto-detect and parse QR code type
        guard let qrCode = BankQRFactory.shared.parseBankQR(from: qrString) else {
            return
        }

        hasScanned = true
        captureSession?.stopRunning()

        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)

        delegate?.didScanBankQR(qrCode)
    }
}

// MARK: - Backward Compatible VietQR Scanner

/// Specific VietQR scanner (for backward compatibility)
public class VietQRScannerViewController: UIViewController {
    public weak var delegate: VietQRScannerDelegate?

    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var hasScanned = false

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
        setupUI()
    }

    private func setupCamera() {
        guard let device = AVCaptureDevice.default(for: .video) else { return }

        do {
            let input = try AVCaptureDeviceInput(device: device)
            let session = AVCaptureSession()
            session.addInput(input)

            let output = AVCaptureMetadataOutput()
            session.addOutput(output)
            output.setMetadataObjectsDelegate(self, queue: .main)
            output.metadataObjectTypes = [.qr]

            self.captureSession = session
        } catch {
            delegate?.didFailScanning(error: error)
        }
    }

    private func setupUI() {
        guard let session = captureSession else { return }

        view.backgroundColor = .black
        title = "Scan VietQR"

        let preview = AVCaptureVideoPreviewLayer(session: session)
        preview.frame = view.bounds
        preview.videoGravity = .resizeAspectFill
        view.layer.addSublayer(preview)
        previewLayer = preview

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelTapped)
        )

        session.startRunning()
    }

    @objc private func cancelTapped() {
        captureSession?.stopRunning()
        dismiss(animated: true)
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
    }
}

extension VietQRScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    public func metadataOutput(_ output: AVCaptureMetadataOutput,
                              didOutput metadataObjects: [AVMetadataObject],
                              from connection: AVCaptureConnection) {
        guard !hasScanned,
              let metadata = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let qrString = metadata.stringValue,
              let vietQR = VietQRParser.shared.parse(from: qrString) else {
            return
        }

        hasScanned = true
        captureSession?.stopRunning()

        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)

        delegate?.didScanVietQR(vietQR)
    }
}
