//
//  LPBankScannerOverlay.swift
//  VNBankQRDemo
//
//  LPBank-styled scanner overlay matching Figma design
//  This is a production-ready overlay that can be used in real banking apps
//

import UIKit
import AVFoundation
import VNBankQR

// MARK: - LPBank Scanner Overlay

/// LPBank-styled scanner overlay matching the Figma design
///
/// Features:
/// - LPBank branding with gold logo
/// - Vietnamese instruction text
/// - Corner-bracketed scan frame (320x320)
/// - Payment method logos (VietQR, VNPay, Napas, SmartPay)
/// - Bottom action buttons (My QR, Upload QR)
/// - Flashlight toggle
/// - Back button
///
/// Usage:
/// ```swift
/// let overlay = LPBankScannerOverlay()
/// let config = ScannerConfiguration(customOverlayViewController: overlay)
/// let scanner = VNBankQR.shared.createScanner(delegate: self, configuration: config)
/// present(scanner, animated: true)
/// ```
class LPBankScannerOverlay: UIViewController, BankQRScannerOverlay {

    // MARK: - UI Components

    private let backButton = UIButton(type: .system)
    private let flashlightButton = UIButton(type: .system)

    private let logoLabel = UILabel()
    private let instructionLabel = UILabel()

    private let scanFrameSize: CGFloat = 320

    private let paymentLogosStack = UIStackView()

    private let bottomActionsContainer = UIView()
    private let myQRButton = UIButton(type: .system)
    private let uploadQRButton = UIButton(type: .system)

    private var isFlashlightOn = false

    // MARK: - BankQRScannerOverlay Protocol

    /// Provide the scan area rectangle to the scanner
    /// This tells AVFoundation where to focus QR detection
    var scanAreaRect: CGRect? {
        // Calculate the exact scan area position
        let scanX = (view.bounds.width - scanFrameSize) / 2
        let scanY = (view.bounds.height - scanFrameSize) / 2 - 20
        return CGRect(x: scanX, y: scanY, width: scanFrameSize, height: scanFrameSize)
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .clear

        // Create dimmed overlay with transparent hole for scan area
        setupDimmedOverlay()

        setupBackButton()
        setupFlashlightButton()
        setupLogo()
        setupInstructionLabel()
        setupScanFrame()
        setupPaymentLogos()
        setupBottomActions()
    }

    private func setupDimmedOverlay() {
        // Create a semi-transparent black overlay with a transparent hole in the center
        let overlayView = UIView(frame: view.bounds)
        overlayView.backgroundColor = .clear
        overlayView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        overlayView.isUserInteractionEnabled = false
        view.addSubview(overlayView)

        // Calculate scan area position (centered)
        let scanX = (view.bounds.width - scanFrameSize) / 2
        let scanY = (view.bounds.height - scanFrameSize) / 2 - 20
        let scanRect = CGRect(x: scanX, y: scanY, width: scanFrameSize, height: scanFrameSize)

        // Create mask with hole
        let maskLayer = CAShapeLayer()
        let path = UIBezierPath(rect: overlayView.bounds)
        let holePath = UIBezierPath(roundedRect: scanRect, cornerRadius: 16)
        path.append(holePath)
        path.usesEvenOddFillRule = true

        maskLayer.path = path.cgPath
        maskLayer.fillRule = .evenOdd
        maskLayer.fillColor = UIColor.black.withAlphaComponent(0.85).cgColor

        overlayView.layer.addSublayer(maskLayer)
    }

    // MARK: - Setup Methods

    private func setupBackButton() {
        backButton.setImage(UIImage(systemName: "arrow.left"), for: .normal)
        backButton.tintColor = .white
        backButton.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        backButton.layer.cornerRadius = 24
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        view.addSubview(backButton)

        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            backButton.widthAnchor.constraint(equalToConstant: 48),
            backButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }

    private func setupFlashlightButton() {
        flashlightButton.setImage(UIImage(systemName: "bolt.fill"), for: .normal)
        flashlightButton.tintColor = .white
        flashlightButton.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        flashlightButton.layer.cornerRadius = 24
        flashlightButton.translatesAutoresizingMaskIntoConstraints = false
        flashlightButton.addTarget(self, action: #selector(toggleFlashlight), for: .touchUpInside)
        view.addSubview(flashlightButton)

        NSLayoutConstraint.activate([
            flashlightButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            flashlightButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            flashlightButton.widthAnchor.constraint(equalToConstant: 48),
            flashlightButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }

    private func setupLogo() {
        // LPBank logo text with gold color
        logoLabel.text = "LPBank"
        logoLabel.font = .systemFont(ofSize: 28, weight: .bold)
        logoLabel.textColor = UIColor(red: 0.85, green: 0.65, blue: 0.13, alpha: 1.0) // Gold #D9A621
        logoLabel.textAlignment = .center
        logoLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoLabel)

        NSLayoutConstraint.activate([
            logoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoLabel.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 40)
        ])

        // TODO: Replace with actual logo image
        // let logoImageView = UIImageView(image: UIImage(named: "lpbank_logo"))
    }

    private func setupInstructionLabel() {
        instructionLabel.text = "Hướng camera đến mã để được\nquét tự động"
        instructionLabel.font = .systemFont(ofSize: 15, weight: .regular)
        instructionLabel.textColor = .white
        instructionLabel.textAlignment = .center
        instructionLabel.numberOfLines = 2
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(instructionLabel)

        NSLayoutConstraint.activate([
            instructionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            instructionLabel.topAnchor.constraint(equalTo: logoLabel.bottomAnchor, constant: 12),
            instructionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            instructionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
    }

    private func setupScanFrame() {
        // Add corner brackets directly to main view at the exact hole position
        addCornerBrackets()
    }

    private func addCornerBrackets() {
        let cornerSize: CGFloat = 40  // Size of corner indicator image

        // Calculate the exact position of the hole (same as in setupDimmedOverlay)
        let scanX = (view.bounds.width - scanFrameSize) / 2
        let scanY = (view.bounds.height - scanFrameSize) / 2 - 20

        // Create separate images for each corner (no rotation needed)
        let topLeftImage = createCornerBracketPlaceholder(size: cornerSize, corner: .topLeft)
        let topRightImage = createCornerBracketPlaceholder(size: cornerSize, corner: .topRight)
        let bottomLeftImage = createCornerBracketPlaceholder(size: cornerSize, corner: .bottomLeft)
        let bottomRightImage = createCornerBracketPlaceholder(size: cornerSize, corner: .bottomRight)

        // Top-left corner - positioned at hole's top-left
        let topLeft = UIImageView(image: topLeftImage)
        topLeft.frame = CGRect(x: scanX, y: scanY, width: cornerSize, height: cornerSize)
        view.addSubview(topLeft)

        // Top-right corner - positioned at hole's top-right
        let topRight = UIImageView(image: topRightImage)
        topRight.frame = CGRect(x: scanX + scanFrameSize - cornerSize, y: scanY, width: cornerSize, height: cornerSize)
        view.addSubview(topRight)

        // Bottom-left corner - positioned at hole's bottom-left
        let bottomLeft = UIImageView(image: bottomLeftImage)
        bottomLeft.frame = CGRect(x: scanX, y: scanY + scanFrameSize - cornerSize, width: cornerSize, height: cornerSize)
        view.addSubview(bottomLeft)

        // Bottom-right corner - positioned at hole's bottom-right
        let bottomRight = UIImageView(image: bottomRightImage)
        bottomRight.frame = CGRect(x: scanX + scanFrameSize - cornerSize, y: scanY + scanFrameSize - cornerSize, width: cornerSize, height: cornerSize)
        view.addSubview(bottomRight)
    }

    enum CornerPosition {
        case topLeft, topRight, bottomLeft, bottomRight
    }

    // MARK: - Corner Images
    // TODO: Add 4 corner images to Assets.xcassets:
    // - corner_top_left (40x40pt, white L-shape, rounded)
    // - corner_top_right (40x40pt, white L-shape, rounded)
    // - corner_bottom_left (40x40pt, white L-shape, rounded)
    // - corner_bottom_right (40x40pt, white L-shape, rounded)
    // Recommended: Export as PDF (vector) or PNG @2x/@3x from Figma

    private func createCornerBracketPlaceholder(size: CGFloat, corner: CornerPosition) -> UIImage {
        let imageName: String
        switch corner {
        case .topLeft: imageName = "corner_top_left"
        case .topRight: imageName = "corner_top_right"
        case .bottomLeft: imageName = "corner_bottom_left"
        case .bottomRight: imageName = "corner_bottom_right"
        }

        // Load from Assets.xcassets
        if let image = UIImage(named: imageName) {
            return image
        }

        // Fallback: return empty transparent image if assets not added yet
        return UIImage()
    }

    private func setupPaymentLogos() {
        paymentLogosStack.axis = .vertical
        paymentLogosStack.spacing = 12
        paymentLogosStack.alignment = .center
        paymentLogosStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(paymentLogosStack)

        // Top row: VietQR, VNPay, Napas logos
        let topRow = createPaymentLogoRow(texts: ["VietQR", "VNPay", "Napas"])
        paymentLogosStack.addArrangedSubview(topRow)

        // Bottom row: napas 247, SmartPay
        let bottomRow = createPaymentLogoRow(texts: ["napas 247", "SmartPay"])
        paymentLogosStack.addArrangedSubview(bottomRow)

        // Position below the scan area (calculated position, not using scanFrameView)
        let scanY = (view.bounds.height - scanFrameSize) / 2 - 20
        let paymentLogosY = scanY + scanFrameSize + 24

        NSLayoutConstraint.activate([
            paymentLogosStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            paymentLogosStack.topAnchor.constraint(equalTo: view.topAnchor, constant: paymentLogosY)
        ])

        // TODO: Replace text labels with actual logo images
        // let vietQRLogo = UIImageView(image: UIImage(named: "vietqr_logo"))
        // let vnpayLogo = UIImageView(image: UIImage(named: "vnpay_logo"))
    }

    private func createPaymentLogoRow(texts: [String]) -> UIStackView {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = 16
        row.alignment = .center

        for text in texts {
            let label = UILabel()
            label.text = text
            label.font = .systemFont(ofSize: 12, weight: .medium)
            label.textColor = .white
            label.textAlignment = .center
            row.addArrangedSubview(label)
        }

        return row
    }

    private func setupBottomActions() {
        bottomActionsContainer.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        bottomActionsContainer.layer.cornerRadius = 16
        bottomActionsContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bottomActionsContainer)

        // My QR button
        myQRButton.setImage(UIImage(systemName: "qrcode"), for: .normal)
        myQRButton.setTitle("Mã QR của tôi", for: .normal)
        myQRButton.tintColor = .white
        myQRButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        myQRButton.translatesAutoresizingMaskIntoConstraints = false
        myQRButton.addTarget(self, action: #selector(myQRTapped), for: .touchUpInside)
        bottomActionsContainer.addSubview(myQRButton)

        // Upload QR button
        uploadQRButton.setImage(UIImage(systemName: "photo"), for: .normal)
        uploadQRButton.setTitle("Tải ảnh QR", for: .normal)
        uploadQRButton.tintColor = .white
        uploadQRButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        uploadQRButton.translatesAutoresizingMaskIntoConstraints = false
        uploadQRButton.addTarget(self, action: #selector(uploadQRTapped), for: .touchUpInside)
        bottomActionsContainer.addSubview(uploadQRButton)

        // Vertical separator
        let separator = UIView()
        separator.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        separator.translatesAutoresizingMaskIntoConstraints = false
        bottomActionsContainer.addSubview(separator)

        NSLayoutConstraint.activate([
            // Container
            bottomActionsContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            bottomActionsContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            bottomActionsContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            bottomActionsContainer.heightAnchor.constraint(equalToConstant: 80),

            // My QR button (left side)
            myQRButton.leadingAnchor.constraint(equalTo: bottomActionsContainer.leadingAnchor, constant: 20),
            myQRButton.centerYAnchor.constraint(equalTo: bottomActionsContainer.centerYAnchor),
            myQRButton.trailingAnchor.constraint(equalTo: bottomActionsContainer.centerXAnchor, constant: -10),

            // Separator
            separator.centerXAnchor.constraint(equalTo: bottomActionsContainer.centerXAnchor),
            separator.centerYAnchor.constraint(equalTo: bottomActionsContainer.centerYAnchor),
            separator.widthAnchor.constraint(equalToConstant: 1),
            separator.heightAnchor.constraint(equalToConstant: 40),

            // Upload QR button (right side)
            uploadQRButton.leadingAnchor.constraint(equalTo: bottomActionsContainer.centerXAnchor, constant: 10),
            uploadQRButton.centerYAnchor.constraint(equalTo: bottomActionsContainer.centerYAnchor),
            uploadQRButton.trailingAnchor.constraint(equalTo: bottomActionsContainer.trailingAnchor, constant: -20)
        ])

        // Configure button layout (icon above text)
        configureVerticalButton(myQRButton)
        configureVerticalButton(uploadQRButton)
    }

    private func configureVerticalButton(_ button: UIButton) {
        // Use modern UIButton.Configuration for iOS 15+
        var config = UIButton.Configuration.plain()
        config.imagePlacement = .top  // Icon above text
        config.imagePadding = 8       // Spacing between icon and text
        config.baseForegroundColor = .white

        // Set title
        var titleAttr = AttributedString(button.title(for: .normal) ?? "")
        titleAttr.font = .systemFont(ofSize: 14, weight: .medium)
        config.attributedTitle = titleAttr

        // Set image
        if let image = button.image(for: .normal) {
            let largerImage = image.withConfiguration(UIImage.SymbolConfiguration(pointSize: 20))
            config.image = largerImage
        }

        button.configuration = config
        button.contentHorizontalAlignment = .center
    }

    // MARK: - Actions

    @objc private func backTapped() {
        presentingViewController?.dismiss(animated: true)
    }

    @objc private func toggleFlashlight() {
        isFlashlightOn.toggle()

        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }

        do {
            try device.lockForConfiguration()
            device.torchMode = isFlashlightOn ? .on : .off
            device.unlockForConfiguration()

            flashlightButton.backgroundColor = isFlashlightOn
                ? UIColor.white.withAlphaComponent(0.4)
                : UIColor.white.withAlphaComponent(0.2)
        } catch {
            print("Flashlight error: \(error)")
        }
    }

    @objc private func myQRTapped() {
        let alert = UIAlertController(
            title: "Mã QR của tôi",
            message: "Hiển thị mã QR cá nhân",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    @objc private func uploadQRTapped() {
        let alert = UIAlertController(
            title: "Tải ảnh QR",
            message: "Chọn ảnh QR từ thư viện",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // MARK: - Cleanup

    deinit {
        // Turn off flashlight when overlay is removed
        if isFlashlightOn {
            guard let device = AVCaptureDevice.default(for: .video) else { return }
            try? device.lockForConfiguration()
            device.torchMode = .off
            device.unlockForConfiguration()
        }
    }
}
