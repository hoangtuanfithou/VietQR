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

    private let scanFrameView = UIView()
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
        guard scanFrameView.superview != nil else { return nil }
        return scanFrameView.frame
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .clear

        setupBackButton()
        setupFlashlightButton()
        setupLogo()
        setupInstructionLabel()
        setupScanFrame()
        setupPaymentLogos()
        setupBottomActions()
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
        scanFrameView.backgroundColor = UIColor.gray.withAlphaComponent(0.3)
        scanFrameView.layer.cornerRadius = 16
        scanFrameView.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        scanFrameView.layer.borderWidth = 2
        scanFrameView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scanFrameView)

        NSLayoutConstraint.activate([
            scanFrameView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scanFrameView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            scanFrameView.widthAnchor.constraint(equalToConstant: scanFrameSize),
            scanFrameView.heightAnchor.constraint(equalToConstant: scanFrameSize)
        ])

        // Add corner brackets (L-shaped indicators)
        addCornerBrackets(to: scanFrameView)
    }

    private func addCornerBrackets(to frameView: UIView) {
        let bracketLength: CGFloat = 40
        let bracketWidth: CGFloat = 4
        let bracketColor = UIColor.white
        let offset: CGFloat = -2

        let corners: [(position: CGPoint, rotation: CGFloat)] = [
            (CGPoint(x: offset, y: offset), 0),                                    // Top-left
            (CGPoint(x: scanFrameSize - bracketLength - offset, y: offset), .pi / 2),   // Top-right
            (CGPoint(x: offset, y: scanFrameSize - bracketLength - offset), -.pi / 2),  // Bottom-left
            (CGPoint(x: scanFrameSize - bracketLength - offset, y: scanFrameSize - bracketLength - offset), .pi) // Bottom-right
        ]

        for (position, rotation) in corners {
            let bracket = UIView(frame: CGRect(x: position.x, y: position.y, width: bracketLength, height: bracketLength))
            bracket.backgroundColor = .clear

            // Create L-shape using two rectangles
            let horizontal = UIView(frame: CGRect(x: 0, y: 0, width: bracketLength, height: bracketWidth))
            horizontal.backgroundColor = bracketColor
            bracket.addSubview(horizontal)

            let vertical = UIView(frame: CGRect(x: 0, y: 0, width: bracketWidth, height: bracketLength))
            vertical.backgroundColor = bracketColor
            bracket.addSubview(vertical)

            bracket.transform = CGAffineTransform(rotationAngle: rotation)
            frameView.addSubview(bracket)
        }
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

        NSLayoutConstraint.activate([
            paymentLogosStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            paymentLogosStack.topAnchor.constraint(equalTo: scanFrameView.bottomAnchor, constant: 24)
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
        button.titleLabel?.textAlignment = .center
        button.imageView?.contentMode = .scaleAspectFit

        // Stack icon above text
        button.contentVerticalAlignment = .center
        button.contentHorizontalAlignment = .center

        let spacing: CGFloat = 4
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: spacing, right: 0)
        button.titleEdgeInsets = UIEdgeInsets(top: spacing, left: -button.imageView!.frame.width, bottom: 0, right: 0)

        // Ensure icon and title are vertically stacked
        button.transform = CGAffineTransform.identity
        button.titleLabel?.numberOfLines = 1
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
