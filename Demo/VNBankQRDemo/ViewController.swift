//
//  ViewController.swift
//  VNBankQRDemo
//
//  Demo app showing VNBankQR package usage
//

import UIKit
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
        accountField.text = "113001180087902"
        amountField.text = "10000"
        descField.text = "QRIBFTTA"
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

        // Example 2: Customize scanner overlay appearance
        let config = ScannerConfiguration(
            scanAreaSize: 280,
            scanAreaCornerRadius: 16,
            overlayColor: UIColor.black.withAlphaComponent(0.6),
            scanAreaBorderColor: .systemGreen,
            scanAreaBorderWidth: 3
        )
        let scanner = VNBankQR.shared.createScanner(delegate: self, configuration: config)

        // Example 3: Use completely custom overlay (uncomment to try)
        // let customOverlay = createCustomOverlay()
        // let customConfig = ScannerConfiguration(customOverlay: customOverlay)
        // let scanner = VNBankQR.shared.createScanner(delegate: self, configuration: customConfig)

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
