//
//  BankQRScannerViewController.swift
//  VNBankQR
//
//  Universal Bank QR scanner - supports all Vietnamese bank QR codes
//  Part 1: Scanner Component
//

import UIKit
import AVFoundation

// MARK: - Scanner Overlay Protocol

/// Protocol for custom scanner overlays to provide scan area information
/// Both UIView and UIViewController overlays can conform to this protocol
public protocol BankQRScannerOverlay {
    /// The frame of the scanning area in the overlay's coordinate system
    /// This will be converted to AVFoundation's rectOfInterest
    /// Return nil to use the full screen as scanning area
    var scanAreaRect: CGRect? { get }
}

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

    // Simulator support
    private var isRunningOnSimulator: Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }

    private var simulatorMockButton: UIButton?

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
        // Skip camera setup on simulator
        if isRunningOnSimulator {
            return
        }

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
        view.backgroundColor = .black
        title = "Scan QR Code"

        // Setup camera preview (only on real device)
        if let session = captureSession {
            let preview = AVCaptureVideoPreviewLayer(session: session)
            preview.frame = view.bounds
            preview.videoGravity = .resizeAspectFill
            view.layer.addSublayer(preview)
            previewLayer = preview

            // Start camera session on background thread to avoid UI blocking
            DispatchQueue.global(qos: .userInitiated).async {
                session.startRunning()
            }
        } else if isRunningOnSimulator {
            // On simulator, show a mock camera background
            let mockCameraView = UIView(frame: view.bounds)
            mockCameraView.backgroundColor = UIColor(white: 0.15, alpha: 1.0)
            mockCameraView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view.addSubview(mockCameraView)

            // Add a label indicating it's simulator mode
            let infoLabel = UILabel()
            infoLabel.text = "Simulator Mode\nCamera preview not available"
            infoLabel.textAlignment = .center
            infoLabel.numberOfLines = 2
            infoLabel.textColor = UIColor.white.withAlphaComponent(0.5)
            infoLabel.font = .systemFont(ofSize: 14, weight: .medium)
            infoLabel.translatesAutoresizingMaskIntoConstraints = false
            mockCameraView.addSubview(infoLabel)

            NSLayoutConstraint.activate([
                infoLabel.centerXAnchor.constraint(equalTo: mockCameraView.centerXAnchor),
                infoLabel.topAnchor.constraint(equalTo: mockCameraView.safeAreaLayoutGuide.topAnchor, constant: 20)
            ])
        }

        // Setup overlay
        setupOverlay()

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelTapped)
        )

        // Add test button for simulator
        if isRunningOnSimulator {
            setupSimulatorTestButton()
        }
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

        // Get scan area from overlay (if it conforms to protocol)
        let scanRect = getScanAreaFromOverlay()

        // Convert to normalized coordinates (0-1) relative to preview layer
        // AVFoundation uses (0,0) at top-left, (1,1) at bottom-right
        let rectOfInterest = previewLayer.metadataOutputRectConverted(fromLayerRect: scanRect)

        // Set the region of interest for faster and more accurate scanning
        metadataOutput.rectOfInterest = rectOfInterest
    }

    private func getScanAreaFromOverlay() -> CGRect {
        // Priority 1: Get from UIViewController overlay (if it conforms to protocol)
        if let overlayVC = overlayViewController as? BankQRScannerOverlay,
           let scanArea = overlayVC.scanAreaRect {
            return scanArea
        }

        // Priority 2: Get from UIView overlay (if it conforms to protocol)
        if let customOverlay = overlayView as? BankQRScannerOverlay,
           let scanArea = customOverlay.scanAreaRect {
            return scanArea
        }

        // Priority 3: Calculate default scan area from configuration
        let scanSize = configuration.scanAreaSize
        let scanX = (view.bounds.width - scanSize) / 2
        let scanY = (view.bounds.height - scanSize) / 2
        return CGRect(x: scanX, y: scanY, width: scanSize, height: scanSize)
    }

    private func setupSimulatorTestButton() {
        let button = UIButton(type: .system)
        button.setTitle("Simulate QR Scan", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = UIColor.systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(simulateQRScan), for: .touchUpInside)
        view.addSubview(button)

        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -140),
            button.widthAnchor.constraint(equalToConstant: 200),
            button.heightAnchor.constraint(equalToConstant: 50)
        ])

        simulatorMockButton = button
    }

    @objc private func simulateQRScan() {
        // Test VietQR string (Valid EMVCo format with proper TLV structure)
        // Bank BIN: 970436, Account: 0011001800879, Amount: 100000, Purpose: "nhan tien"
        let testVietQRString = "00020101021238570010A00000072701270006970436011300110018008790208QRIBFTTA530370454061000005802VN62130809nhan tien6304D1EF"

        // Parse using factory
        guard let qrCode = BankQRFactory.shared.parseBankQR(from: testVietQRString) else {
            showSimulatorAlert(title: "Parse Failed", message: "Could not parse test QR code")
            return
        }

        // Mark as scanned
        hasScanned = true

        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)

        // Notify delegate
        delegate?.didScanBankQR(qrCode)
    }

    private func showSimulatorAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    @objc private func cancelTapped() {
        // Stop camera session on background thread
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession?.stopRunning()
        }
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

        // Start camera session on background thread
        DispatchQueue.global(qos: .userInitiated).async {
            session.startRunning()
        }
    }

    @objc private func cancelTapped() {
        // Stop camera session on background thread
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession?.stopRunning()
        }
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
