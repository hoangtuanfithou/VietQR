//
//  ViewController.swift
//  VNBankQRDemo
//
//  Demo app showing VNBankQR package usage
//

import UIKit
import AVFoundation
import VNBankQR

class ViewController: UIViewController {

    private let scrollView = UIScrollView()
    private let stackView = UIStackView()

    private let bankBinField = UITextField()
    private let accountField = UITextField()
    private let amountField = UITextField()
    private let descField = UITextField()

    private let qrImageView = UIImageView()
    private let qrStringLabel = UILabel()
    private let resultLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupDemo()
    }

    private func setupUI() {
        title = "VNBankQR Demo"
        view.backgroundColor = .systemBackground

        // ScrollView
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        // StackView
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)

        // Input fields
        [bankBinField, accountField, amountField, descField].forEach { field in
            field.borderStyle = .roundedRect
            field.autocorrectionType = .no
            field.autocapitalizationType = .none
            stackView.addArrangedSubview(field)
        }

        bankBinField.placeholder = "Bank BIN (6 digits)"
        bankBinField.keyboardType = .numberPad
        accountField.placeholder = "Account Number"
        amountField.placeholder = "Amount (optional)"
        amountField.keyboardType = .numberPad
        descField.placeholder = "Description (optional)"

        // Generate button
        let generateBtn = UIButton(type: .system)
        generateBtn.setTitle("Generate QR Code", for: .normal)
        generateBtn.backgroundColor = .systemBlue
        generateBtn.setTitleColor(.white, for: .normal)
        generateBtn.layer.cornerRadius = 12
        generateBtn.heightAnchor.constraint(equalToConstant: 50).isActive = true
        generateBtn.addTarget(self, action: #selector(generateTapped), for: .touchUpInside)
        stackView.addArrangedSubview(generateBtn)

        // QR Image
        qrImageView.contentMode = .scaleAspectFit
        qrImageView.backgroundColor = .white
        qrImageView.layer.borderWidth = 1
        qrImageView.layer.borderColor = UIColor.systemGray4.cgColor
        qrImageView.heightAnchor.constraint(equalToConstant: 300).isActive = true
        stackView.addArrangedSubview(qrImageView)

        // QR String
        qrStringLabel.font = .monospacedSystemFont(ofSize: 8, weight: .regular)
        qrStringLabel.numberOfLines = 0
        qrStringLabel.textColor = .systemGray
        stackView.addArrangedSubview(qrStringLabel)

        // Action buttons
        let scanBtn = createButton(title: "📷 Scan QR", action: #selector(scanTapped))
        let selectBtn = createButton(title: "🖼 Select Image", action: #selector(selectTapped))
        let testBtn = createButton(title: "🧪 Test Parse", action: #selector(testTapped))

        [scanBtn, selectBtn, testBtn].forEach { stackView.addArrangedSubview($0) }

        // Result
        resultLabel.font = .systemFont(ofSize: 14)
        resultLabel.numberOfLines = 0
        stackView.addArrangedSubview(resultLabel)

        // Constraints
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
        ])

        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
    }

    private func createButton(title: String, action: Selector) -> UIButton {
        let btn = UIButton(type: .system)
        btn.setTitle(title, for: .normal)
        btn.backgroundColor = .systemGray5
        btn.setTitleColor(.label, for: .normal)
        btn.layer.cornerRadius = 12
        btn.heightAnchor.constraint(equalToConstant: 50).isActive = true
        btn.addTarget(self, action: action, for: .touchUpInside)
        return btn
    }

    private func setupDemo() {
        bankBinField.text = "970436"
        accountField.text = "0011001800879"
        amountField.text = "10000"
        descField.text = "transfer money"
    }

    @objc private func generateTapped() {
        guard let bin = bankBinField.text, !bin.isEmpty,
              let account = accountField.text, !account.isEmpty else {
            showAlert("Please enter Bank BIN and Account Number")
            return
        }

        let vietQR = VietQR(
            bankBin: bin,
            accountNumber: account,
            accountName: nil,
            amount: amountField.text,
            purpose: descField.text
        )

        let qrString = VNBankQR.shared.generateVietQRString(from: vietQR)
        qrStringLabel.text = qrString

        if let image = VNBankQR.shared.generateVietQRImage(from: vietQR) {
            qrImageView.image = image
            resultLabel.text = "✅ Generated:\n\n" + vietQR.displayInfo
        }
    }

    @objc private func scanTapped() {
        // Example 1: Use default scanner with default overlay
        // let scanner = VNBankQR.shared.createScanner(delegate: self)

        // Example 2: Customize scanner overlay appearance (UIView)
        // let config = ScannerConfiguration(
        //     scanAreaSize: 280,
        //     scanAreaCornerRadius: 16,
        //     overlayColor: UIColor.black.withAlphaComponent(0.6),
        //     scanAreaBorderColor: .systemGreen,
        //     scanAreaBorderWidth: 3
        // )
        // let scanner = VNBankQR.shared.createScanner(delegate: self, configuration: config)

        // Example 3: Use custom UIView overlay (uncomment to try)
        // let customOverlay = createCustomOverlay()
        // let customConfig = ScannerConfiguration(customOverlay: customOverlay)
        // let scanner = VNBankQR.shared.createScanner(delegate: self, configuration: customConfig)

        // Example 4: Use custom UIViewController overlay (best for complex UI)
        let overlayVC = createCustomOverlayViewController()
        let config = ScannerConfiguration(customOverlayViewController: overlayVC)
        let scanner = VNBankQR.shared.createScanner(delegate: self, configuration: config)

        present(scanner, animated: true)
    }

    // Example: Create custom overlay view with instructions
    private func createCustomOverlay() -> UIView {
        let overlay = UIView()
        overlay.backgroundColor = .clear

        // Add instruction label at top
        let instructionLabel = UILabel()
        instructionLabel.text = "Align QR code within the frame"
        instructionLabel.textColor = .white
        instructionLabel.font = .systemFont(ofSize: 16, weight: .medium)
        instructionLabel.textAlignment = .center
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        overlay.addSubview(instructionLabel)

        NSLayoutConstraint.activate([
            instructionLabel.topAnchor.constraint(equalTo: overlay.safeAreaLayoutGuide.topAnchor, constant: 40),
            instructionLabel.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
            instructionLabel.leadingAnchor.constraint(equalTo: overlay.leadingAnchor, constant: 20),
            instructionLabel.trailingAnchor.constraint(equalTo: overlay.trailingAnchor, constant: -20)
        ])

        // Add scan frame with corners
        let scanSize: CGFloat = 280
        let scanFrame = UIView()
        scanFrame.backgroundColor = .clear
        scanFrame.translatesAutoresizingMaskIntoConstraints = false
        overlay.addSubview(scanFrame)

        NSLayoutConstraint.activate([
            scanFrame.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
            scanFrame.centerYAnchor.constraint(equalTo: overlay.centerYAnchor),
            scanFrame.widthAnchor.constraint(equalToConstant: scanSize),
            scanFrame.heightAnchor.constraint(equalToConstant: scanSize)
        ])

        // Add corner indicators
        let cornerLength: CGFloat = 30
        let cornerWidth: CGFloat = 4
        let corners = [
            (CGPoint(x: 0, y: 0), [true, false, false, true]),  // Top-left
            (CGPoint(x: scanSize - cornerLength, y: 0), [true, true, false, false]),  // Top-right
            (CGPoint(x: 0, y: scanSize - cornerLength), [false, false, true, true]),  // Bottom-left
            (CGPoint(x: scanSize - cornerLength, y: scanSize - cornerLength), [false, true, true, false])  // Bottom-right
        ]

        for (position, sides) in corners {
            let corner = UIView(frame: CGRect(x: position.x, y: position.y, width: cornerLength, height: cornerLength))
            corner.backgroundColor = .clear

            if sides[0] { // Top
                let top = UIView(frame: CGRect(x: 0, y: 0, width: cornerLength, height: cornerWidth))
                top.backgroundColor = .systemGreen
                corner.addSubview(top)
            }
            if sides[1] { // Right
                let right = UIView(frame: CGRect(x: cornerLength - cornerWidth, y: 0, width: cornerWidth, height: cornerLength))
                right.backgroundColor = .systemGreen
                corner.addSubview(right)
            }
            if sides[2] { // Bottom
                let bottom = UIView(frame: CGRect(x: 0, y: cornerLength - cornerWidth, width: cornerLength, height: cornerWidth))
                bottom.backgroundColor = .systemGreen
                corner.addSubview(bottom)
            }
            if sides[3] { // Left
                let left = UIView(frame: CGRect(x: 0, y: 0, width: cornerWidth, height: cornerLength))
                left.backgroundColor = .systemGreen
                corner.addSubview(left)
            }

            scanFrame.addSubview(corner)
        }

        return overlay
    }

    // Example: Create custom overlay as UIViewController (recommended for complex UI)
    private func createCustomOverlayViewController() -> UIViewController {
        // Use LPBank-styled overlay
        let overlayVC = LPBankScannerOverlay()
        return overlayVC

        // Or use the generic example overlay
        // let overlayVC = ScannerOverlayViewController()
        // return overlayVC
    }

    @objc private func selectTapped() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        present(picker, animated: true)
    }

    @objc private func testTapped() {
        // Test with actual sample from NAPAS spec
        let sample = "00020101021238570010A00000072701270006970436011300110018008790208QRIBFTTA530370454061000005802VN62130809nhan tien6304D1EF"

        print("=== Testing VietQR Parser ===")
        print("Input: \(sample)")
        print("")

        if let vietQR = VNBankQR.shared.parseVietQR(qrString: sample) {
            print("✅ Parsed Successfully!")
            print("")
            print("Bank BIN: \(vietQR.bankBin)")
            print("Account Number: \(vietQR.accountNumber)")
            print("Account Name: \(vietQR.accountName ?? "N/A")")
            print("Amount: \(vietQR.amount ?? "N/A")")
            print("Purpose: \(vietQR.purpose ?? "N/A")")
            print("Service Code: \(vietQR.serviceCode)")

            // Verify bank
            if let bank = VietQRBankDirectory.shared.getBank(bin: vietQR.bankBin) {
                print("Bank Name: \(bank.shortName)")
            }

            // Update UI
            bankBinField.text = vietQR.bankBin
            accountField.text = vietQR.accountNumber
            amountField.text = vietQR.amount
            descField.text = vietQR.purpose

            resultLabel.text = "✅ Parsed from sample:\n\n" + vietQR.displayInfo

            // Generate QR image to verify round-trip
            if let image = VNBankQR.shared.generateVietQRImage(from: vietQR) {
                qrImageView.image = image

                // Test regeneration
                let regenerated = VNBankQR.shared.generateVietQRString(from: vietQR)
                print("")
                print("Regenerated: \(regenerated)")

                // Verify CRC
                let originalCRC = String(sample.suffix(4))
                let regeneratedCRC = String(regenerated.suffix(4))
                print("")
                print("Original CRC: \(originalCRC)")
                print("Regenerated CRC: \(regeneratedCRC)")

                if originalCRC == regeneratedCRC {
                    print("✅ CRC Match - Perfect round-trip!")
                } else {
                    print("⚠️ CRC Mismatch - Check implementation")
                }
            }

            print("")
            print("=== Expected Values ===")
            print("Bank BIN: 970436 (Vietcombank)")
            print("Account: 0011001800879")
            print("Amount: 100000")
            print("Purpose: nhan tien")

        } else {
            print("❌ Parsing Failed!")
            showAlert("Failed to parse sample QR string")
        }
    }

    private func showAlert(_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - BankQRScannerDelegate

extension ViewController: BankQRScannerDelegate {
    func didScanBankQR(_ qrCode: any BankQRProtocol) {
        dismiss(animated: true)

        if let vietQR = qrCode as? VietQR {
            bankBinField.text = vietQR.bankBin
            accountField.text = vietQR.accountNumber
            amountField.text = vietQR.amount
            descField.text = vietQR.purpose
            resultLabel.text = "✅ Scanned:\n\n" + vietQR.displayInfo
        }
    }

    func didFailScanning(error: BankQRError) {
        dismiss(animated: true)
        showAlert("Scan failed: \(error.localizedDescription)")
    }
}

// MARK: - UIImagePickerControllerDelegate

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                              didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)

        guard let image = info[.originalImage] as? UIImage,
              let vietQR = VNBankQR.shared.parseVietQR(image: image) else {
            showAlert("No VietQR found in image")
            return
        }

        bankBinField.text = vietQR.bankBin
        accountField.text = vietQR.accountNumber
        amountField.text = vietQR.amount
        descField.text = vietQR.purpose
        resultLabel.text = "✅ Parsed from image:\n\n" + vietQR.displayInfo
    }
}

// MARK: - Custom Scanner Overlay ViewController Example

/// Example of a custom UIViewController overlay for the scanner
/// This demonstrates the recommended approach for complex scanner UI with:
/// - Instructions and help text
/// - Toggle for flashlight
/// - Manual entry button
/// - Full view controller lifecycle
/// - Conforms to BankQRScannerOverlay protocol to provide scan area
class ScannerOverlayViewController: UIViewController, BankQRScannerOverlay {

    private let instructionLabel = UILabel()
    private let scanFrameView = UIView()
    private let flashlightButton = UIButton(type: .system)
    private let manualEntryButton = UIButton(type: .system)
    private var isFlashlightOn = false

    // MARK: - BankQRScannerOverlay Protocol

    /// Provide the scan area rectangle to the scanner
    /// This tells AVFoundation where to focus QR detection
    var scanAreaRect: CGRect? {
        // Return the frame of the scan area in the view's coordinate system
        // The scanner will convert this to AVFoundation's rectOfInterest
        guard scanFrameView.superview != nil else { return nil }
        return scanFrameView.frame
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .clear

        // Instruction label at top
        instructionLabel.text = "Align QR code within the frame"
        instructionLabel.textColor = .white
        instructionLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        instructionLabel.textAlignment = .center
        instructionLabel.numberOfLines = 0
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(instructionLabel)

        // Scan frame in center
        scanFrameView.backgroundColor = .clear
        scanFrameView.layer.borderColor = UIColor.systemGreen.cgColor
        scanFrameView.layer.borderWidth = 3
        scanFrameView.layer.cornerRadius = 16
        scanFrameView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scanFrameView)

        // Add corner indicators to scan frame
        addCornerIndicators(to: scanFrameView)

        // Flashlight button
        flashlightButton.setImage(UIImage(systemName: "flashlight.off.fill"), for: .normal)
        flashlightButton.tintColor = .white
        flashlightButton.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        flashlightButton.layer.cornerRadius = 30
        flashlightButton.translatesAutoresizingMaskIntoConstraints = false
        flashlightButton.addTarget(self, action: #selector(toggleFlashlight), for: .touchUpInside)
        view.addSubview(flashlightButton)

        // Manual entry button
        manualEntryButton.setTitle("Enter Manually", for: .normal)
        manualEntryButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        manualEntryButton.tintColor = .white
        manualEntryButton.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.8)
        manualEntryButton.layer.cornerRadius = 12
        manualEntryButton.translatesAutoresizingMaskIntoConstraints = false
        manualEntryButton.addTarget(self, action: #selector(manualEntryTapped), for: .touchUpInside)
        view.addSubview(manualEntryButton)

        // Layout constraints
        NSLayoutConstraint.activate([
            // Instruction label
            instructionLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            instructionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            instructionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            // Scan frame
            scanFrameView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scanFrameView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            scanFrameView.widthAnchor.constraint(equalToConstant: 280),
            scanFrameView.heightAnchor.constraint(equalToConstant: 280),

            // Flashlight button
            flashlightButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            flashlightButton.centerYAnchor.constraint(equalTo: scanFrameView.centerYAnchor),
            flashlightButton.widthAnchor.constraint(equalToConstant: 60),
            flashlightButton.heightAnchor.constraint(equalToConstant: 60),

            // Manual entry button
            manualEntryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            manualEntryButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            manualEntryButton.widthAnchor.constraint(equalToConstant: 200),
            manualEntryButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    private func addCornerIndicators(to frameView: UIView) {
        let cornerLength: CGFloat = 30
        let cornerWidth: CGFloat = 4
        let offset: CGFloat = -3  // Offset to align with border

        // Create corner paths
        let corners: [(UIRectCorner, CGPoint)] = [
            (.topLeft, CGPoint(x: offset, y: offset)),
            (.topRight, CGPoint(x: 280 - cornerLength - offset, y: offset)),
            (.bottomLeft, CGPoint(x: offset, y: 280 - cornerLength - offset)),
            (.bottomRight, CGPoint(x: 280 - cornerLength - offset, y: 280 - cornerLength - offset))
        ]

        for (corner, position) in corners {
            let cornerView = UIView(frame: CGRect(x: position.x, y: position.y, width: cornerLength, height: cornerLength))
            cornerView.backgroundColor = .clear

            // Create L-shaped corner
            let path = UIBezierPath()
            switch corner {
            case .topLeft:
                // Horizontal line
                path.move(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: cornerLength, y: 0))
                path.addLine(to: CGPoint(x: cornerLength, y: cornerWidth))
                path.addLine(to: CGPoint(x: cornerWidth, y: cornerWidth))
                // Vertical line
                path.addLine(to: CGPoint(x: cornerWidth, y: cornerLength))
                path.addLine(to: CGPoint(x: 0, y: cornerLength))
                path.close()
            case .topRight:
                // Horizontal line
                path.move(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: cornerLength, y: 0))
                path.addLine(to: CGPoint(x: cornerLength, y: cornerLength))
                path.addLine(to: CGPoint(x: cornerLength - cornerWidth, y: cornerLength))
                // Vertical line
                path.addLine(to: CGPoint(x: cornerLength - cornerWidth, y: cornerWidth))
                path.addLine(to: CGPoint(x: 0, y: cornerWidth))
                path.close()
            case .bottomLeft:
                // Vertical line
                path.move(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: cornerWidth, y: 0))
                path.addLine(to: CGPoint(x: cornerWidth, y: cornerLength - cornerWidth))
                // Horizontal line
                path.addLine(to: CGPoint(x: cornerLength, y: cornerLength - cornerWidth))
                path.addLine(to: CGPoint(x: cornerLength, y: cornerLength))
                path.addLine(to: CGPoint(x: 0, y: cornerLength))
                path.close()
            case .bottomRight:
                // Horizontal line
                path.move(to: CGPoint(x: 0, y: cornerLength - cornerWidth))
                path.addLine(to: CGPoint(x: cornerLength - cornerWidth, y: cornerLength - cornerWidth))
                // Vertical line
                path.addLine(to: CGPoint(x: cornerLength - cornerWidth, y: 0))
                path.addLine(to: CGPoint(x: cornerLength, y: 0))
                path.addLine(to: CGPoint(x: cornerLength, y: cornerLength))
                path.addLine(to: CGPoint(x: 0, y: cornerLength))
                path.close()
            default:
                break
            }

            let shapeLayer = CAShapeLayer()
            shapeLayer.path = path.cgPath
            shapeLayer.fillColor = UIColor.systemGreen.cgColor
            cornerView.layer.addSublayer(shapeLayer)

            frameView.addSubview(cornerView)
        }
    }

    @objc private func toggleFlashlight() {
        isFlashlightOn.toggle()

        // Toggle flashlight on device
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }

        do {
            try device.lockForConfiguration()
            device.torchMode = isFlashlightOn ? .on : .off
            device.unlockForConfiguration()

            // Update button
            let imageName = isFlashlightOn ? "flashlight.on.fill" : "flashlight.off.fill"
            flashlightButton.setImage(UIImage(systemName: imageName), for: .normal)
        } catch {
            print("Failed to toggle flashlight: \(error)")
        }
    }

    @objc private func manualEntryTapped() {
        // In a real app, you would show a manual entry form here
        let alert = UIAlertController(
            title: "Manual Entry",
            message: "Manual entry form would appear here",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

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

// NOTE: LPBankScannerOverlay has been moved to a separate file:
// See: LPBankScannerOverlay.swift
