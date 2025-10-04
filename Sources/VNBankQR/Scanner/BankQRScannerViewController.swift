//
//  BankQRScannerViewController.swift
//  VNBankQR
//
//  Universal Bank QR scanner - supports all Vietnamese bank QR codes
//  Part 1: Scanner Component
//

import UIKit
import AVFoundation

// MARK: - Scanner Configuration

/// Configuration for scanner overlay and scanning area
public struct ScannerConfiguration {
    /// Custom overlay as UIViewController (recommended for complex UI)
    /// Takes priority over customOverlay if both are provided
    public var customOverlayViewController: UIViewController?

    /// Custom overlay as UIView (for simple overlays)
    /// Used only if customOverlayViewController is nil
    public var customOverlay: UIView?

    /// Scanning area size (width and height will be equal for square)
    /// Default is 250x250
    public var scanAreaSize: CGFloat

    /// Corner radius for the scan area
    public var scanAreaCornerRadius: CGFloat

    /// Overlay background color (area outside scan square)
    /// Only used for default overlay
    public var overlayColor: UIColor

    /// Scan area border color
    /// Only used for default overlay
    public var scanAreaBorderColor: UIColor

    /// Scan area border width
    /// Only used for default overlay
    public var scanAreaBorderWidth: CGFloat

    public init(
        customOverlayViewController: UIViewController? = nil,
        customOverlay: UIView? = nil,
        scanAreaSize: CGFloat = 250,
        scanAreaCornerRadius: CGFloat = 12,
        overlayColor: UIColor = UIColor.black.withAlphaComponent(0.5),
        scanAreaBorderColor: UIColor = .white,
        scanAreaBorderWidth: CGFloat = 2
    ) {
        self.customOverlayViewController = customOverlayViewController
        self.customOverlay = customOverlay
        self.scanAreaSize = scanAreaSize
        self.scanAreaCornerRadius = scanAreaCornerRadius
        self.overlayColor = overlayColor
        self.scanAreaBorderColor = scanAreaBorderColor
        self.scanAreaBorderWidth = scanAreaBorderWidth
    }
}

// MARK: - Universal Bank QR Scanner

/// Universal Bank QR scanner that can detect and parse any registered Vietnamese bank QR code
public class BankQRScannerViewController: UIViewController {
    public weak var delegate: BankQRScannerDelegate?

    /// Scanner configuration (overlay and scan area)
    public var configuration: ScannerConfiguration = ScannerConfiguration()

    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var metadataOutput: AVCaptureMetadataOutput?
    private var hasScanned = false

    private var overlayView: UIView?
    private var overlayViewController: UIViewController?
    private var scanAreaView: UIView?

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
        setupUI()
    }

    deinit {
        // Clean up child view controller if needed
        if let overlayVC = overlayViewController {
            overlayVC.willMove(toParent: nil)
            overlayVC.view.removeFromSuperview()
            overlayVC.removeFromParent()
        }
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
            self.metadataOutput = output
        } catch {
            delegate?.didFailScanning(error: .cameraNotAvailable)
        }
    }

    private func setupUI() {
        guard let session = captureSession else { return }

        view.backgroundColor = .black
        title = "Scan QR Code"

        // Setup camera preview
        let preview = AVCaptureVideoPreviewLayer(session: session)
        preview.frame = view.bounds
        preview.videoGravity = .resizeAspectFill
        view.layer.addSublayer(preview)
        previewLayer = preview

        // Setup overlay
        setupOverlay()

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelTapped)
        )

        session.startRunning()
    }

    private func setupOverlay() {
        // Priority 1: Use custom UIViewController overlay (best for complex UI)
        if let customOverlayVC = configuration.customOverlayViewController {
            setupViewControllerOverlay(customOverlayVC)
        }
        // Priority 2: Use custom UIView overlay (for simple overlays)
        else if let customOverlay = configuration.customOverlay {
            setupViewOverlay(customOverlay)
        }
        // Priority 3: Use default overlay
        else {
            createDefaultOverlay()
        }

        // Update scan area region of interest after layout
        DispatchQueue.main.async { [weak self] in
            self?.updateScanAreaRegion()
        }
    }

    private func setupViewControllerOverlay(_ overlayVC: UIViewController) {
        // Proper child view controller containment
        addChild(overlayVC)
        overlayVC.view.frame = view.bounds
        overlayVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(overlayVC.view)
        overlayVC.didMove(toParent: self)

        // Store reference for cleanup
        overlayViewController = overlayVC
        overlayView = overlayVC.view
    }

    private func setupViewOverlay(_ customOverlay: UIView) {
        customOverlay.frame = view.bounds
        customOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(customOverlay)
        overlayView = customOverlay
    }

    private func createDefaultOverlay() {
        let overlay = UIView(frame: view.bounds)
        overlay.backgroundColor = .clear
        view.addSubview(overlay)
        overlayView = overlay

        // Create dimmed background with clear center
        let maskLayer = CAShapeLayer()
        let path = UIBezierPath(rect: overlay.bounds)

        // Calculate scan area position (centered)
        let scanSize = configuration.scanAreaSize
        let scanX = (overlay.bounds.width - scanSize) / 2
        let scanY = (overlay.bounds.height - scanSize) / 2
        let scanRect = CGRect(x: scanX, y: scanY, width: scanSize, height: scanSize)

        // Cut out the scan area
        let scanPath = UIBezierPath(roundedRect: scanRect, cornerRadius: configuration.scanAreaCornerRadius)
        path.append(scanPath)
        path.usesEvenOddFillRule = true

        maskLayer.path = path.cgPath
        maskLayer.fillRule = .evenOdd
        maskLayer.fillColor = configuration.overlayColor.cgColor
        overlay.layer.addSublayer(maskLayer)

        // Create scan area border
        let borderView = UIView(frame: scanRect)
        borderView.layer.cornerRadius = configuration.scanAreaCornerRadius
        borderView.layer.borderColor = configuration.scanAreaBorderColor.cgColor
        borderView.layer.borderWidth = configuration.scanAreaBorderWidth
        borderView.backgroundColor = .clear
        overlay.addSubview(borderView)
        scanAreaView = borderView
    }

    private func updateScanAreaRegion() {
        guard let previewLayer = previewLayer,
              let metadataOutput = metadataOutput else { return }

        // Calculate scan area in view coordinates
        let scanSize = configuration.scanAreaSize
        let scanX = (view.bounds.width - scanSize) / 2
        let scanY = (view.bounds.height - scanSize) / 2
        let scanRect = CGRect(x: scanX, y: scanY, width: scanSize, height: scanSize)

        // Convert to normalized coordinates (0-1) relative to preview layer
        // AVFoundation uses (0,0) at top-left, (1,1) at bottom-right
        let rectOfInterest = previewLayer.metadataOutputRectConverted(fromLayerRect: scanRect)

        // Set the region of interest for faster and more accurate scanning
        metadataOutput.rectOfInterest = rectOfInterest
    }

    @objc private func cancelTapped() {
        captureSession?.stopRunning()
        dismiss(animated: true)
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
        overlayView?.frame = view.bounds

        // Recreate overlay with new bounds if using default
        // Don't recreate if using custom UIView or UIViewController
        if configuration.customOverlayViewController == nil && configuration.customOverlay == nil {
            overlayView?.removeFromSuperview()
            createDefaultOverlay()
        }

        updateScanAreaRegion()
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
