//
//  VietQR.swift
//  VietQR
//
//  Created by admin on 30/9/25.
//

/// VietQR standard data structure
public struct VietQR2 {
    public let bankBin: String
    public let accountNumber: String
    public let template: String
    public let amount: String?
    public let description: String?
    public let accountName: String?

    public init(
        bankBin: String,
        accountNumber: String,
        template: String = "compact2",
        amount: String? = nil,
        description: String? = nil,
        accountName: String? = nil
    ) {
        self.bankBin = bankBin
        self.accountNumber = accountNumber
        self.template = template
        self.amount = amount
        self.description = description
        self.accountName = accountName
    }
}

// MARK: - VietQR Core Library
// File: VietQR.swift

import Foundation
import UIKit
import CoreImage

// MARK: - Models

/// VietQR data model following EMV QCO specification
public struct VietQR {
    public var bankBin: String
    public var accountNumber: String
    public var amount: String?
    public var description: String?

    // EMV Standard fields
    public var serviceCode: String = "QRIBFTTA"
    public var additionalData: AdditionalData?

    public struct AdditionalData {
        public var purpose: String?
        public var reference: String?
        public var billNumber: String?
        public var mobileNumber: String?
        public var store: String?

        public init(purpose: String? = nil, reference: String? = nil, billNumber: String? = nil,
                    mobileNumber: String? = nil, store: String? = nil) {
            self.purpose = purpose
            self.reference = reference
            self.billNumber = billNumber
            self.mobileNumber = mobileNumber
            self.store = store
        }
    }

    public init(bankBin: String, accountNumber: String, amount: String? = nil, description: String? = nil) {
        self.bankBin = bankBin
        self.accountNumber = accountNumber
        self.amount = amount
        self.description = description

        if let desc = description {
            self.additionalData = AdditionalData(purpose: desc)
        }
    }
}

// MARK: - VietQR Parser & Generator

public class VietQRService {
    public static let shared = VietQRService()
    private init() {}

    // MARK: - Parse from String

    /// Parse VietQR from EMV QCO string format
    /// - Parameter qrString: EMV format string (e.g., "00020101021238570010A000000727...")
    /// - Returns: VietQR object or nil if parsing fails
    public func parse(from qrString: String) -> VietQR? {
        let fields = parseTLV(qrString)

        // Validate format
        guard fields["00"] == "01" else { return nil }

        // Parse merchant info (Tag 38 for VietQR)
        guard let merchantInfo = fields["38"] else { return nil }
        let merchantFields = parseTLV(merchantInfo)

        guard let bankBin = merchantFields["01"],
              let accountNumber = merchantFields["02"] else {
            return nil
        }

        var vietQR = VietQR(bankBin: bankBin, accountNumber: accountNumber)

        // Optional amount
        vietQR.amount = fields["54"]

        // Parse additional data
        if let additionalInfo = fields["62"] {
            let additionalFields = parseTLV(additionalInfo)
            var additionalData = VietQR.AdditionalData()
            additionalData.purpose = additionalFields["08"]
            additionalData.reference = additionalFields["05"]
            additionalData.billNumber = additionalFields["01"]
            additionalData.mobileNumber = additionalFields["02"]
            additionalData.store = additionalFields["03"]

            vietQR.additionalData = additionalData
            vietQR.description = additionalData.purpose
        }

        // Service code
        if let serviceCode = merchantFields["03"] {
            vietQR.serviceCode = serviceCode
        }

        return vietQR
    }

    // MARK: - Generate String

    /// Generate EMV QCO string from VietQR object
    /// - Parameter vietQR: VietQR object
    /// - Returns: EMV format string
    public func generate(from vietQR: VietQR) -> String {
        var result = ""

        // 00: Payload Format Indicator
        result += buildTLV("00", "01")

        // 01: Point of Initiation Method (11 = static, 12 = dynamic)
        result += buildTLV("01", "11")

        // 38: Merchant Account Information (VietQR)
        var merchantInfo = ""
        merchantInfo += buildTLV("00", "A000000727")  // GUID
        merchantInfo += buildTLV("01", vietQR.bankBin)
        merchantInfo += buildTLV("02", vietQR.accountNumber)
        merchantInfo += buildTLV("03", vietQR.serviceCode)
        result += buildTLV("38", merchantInfo)

        // 53: Transaction Currency (704 = VND)
        result += buildTLV("53", "704")

        // 54: Transaction Amount (optional)
        if let amount = vietQR.amount, !amount.isEmpty {
            result += buildTLV("54", amount)
        }

        // 58: Country Code
        result += buildTLV("58", "VN")

        // 62: Additional Data (optional)
        if let additional = vietQR.additionalData {
            var additionalStr = ""

            if let billNumber = additional.billNumber {
                additionalStr += buildTLV("01", billNumber)
            }
            if let mobile = additional.mobileNumber {
                additionalStr += buildTLV("02", mobile)
            }
            if let store = additional.store {
                additionalStr += buildTLV("03", store)
            }
            if let reference = additional.reference {
                additionalStr += buildTLV("05", reference)
            }
            if let purpose = additional.purpose {
                additionalStr += buildTLV("08", purpose)
            }

            if !additionalStr.isEmpty {
                result += buildTLV("62", additionalStr)
            }
        }

        // 63: CRC (always last)
        result += "6304"
        let crc = calculateCRC(result)
        result += crc

        return result
    }

    // MARK: - Generate QR Image

    /// Generate QR code image from VietQR object
    /// - Parameters:
    ///   - vietQR: VietQR object
    ///   - size: Desired image size (default: 300x300)
    /// - Returns: UIImage or nil if generation fails
    public func generateQRImage(from vietQR: VietQR, size: CGSize = CGSize(width: 300, height: 300)) -> UIImage? {
        let qrString = generate(from: vietQR)
        return generateQRImage(from: qrString, size: size)
    }

    /// Generate QR code image from string
    /// - Parameters:
    ///   - qrString: EMV format string
    ///   - size: Desired image size
    /// - Returns: UIImage or nil if generation fails
    public func generateQRImage(from qrString: String, size: CGSize) -> UIImage? {
        guard let data = qrString.data(using: .utf8),
              let filter = CIFilter(name: "CIQRCodeGenerator") else {
            return nil
        }

        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("H", forKey: "inputCorrectionLevel")

        guard let ciImage = filter.outputImage else { return nil }

        let scaleX = size.width / ciImage.extent.width
        let scaleY = size.height / ciImage.extent.height
        let transform = CGAffineTransform(scaleX: scaleX, y: scaleY)
        let scaledImage = ciImage.transformed(by: transform)

        let context = CIContext()
        guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else {
            return nil
        }

        return UIImage(cgImage: cgImage)
    }

    // MARK: - Parse from Image

    /// Parse VietQR from QR code image
    /// - Parameter image: UIImage containing QR code
    /// - Returns: VietQR object or nil if parsing fails
    public func parse(from image: UIImage) -> VietQR? {
        guard let ciImage = CIImage(image: image),
              let detector = CIDetector(ofType: CIDetectorTypeQRCode,
                                       context: nil,
                                       options: [CIDetectorAccuracy: CIDetectorAccuracyHigh]) else {
            return nil
        }

        let features = detector.features(in: ciImage)

        for feature in features {
            if let qrFeature = feature as? CIQRCodeFeature,
               let messageString = qrFeature.messageString {
                return parse(from: messageString)
            }
        }

        return nil
    }

    // MARK: - Helper Methods

    private func parseTLV(_ data: String) -> [String: String] {
        var result: [String: String] = [:]
        var index = data.startIndex

        while index < data.endIndex {
            guard data.distance(from: index, to: data.endIndex) >= 4 else { break }

            let tagEnd = data.index(index, offsetBy: 2)
            let tag = String(data[index..<tagEnd])

            let lengthEnd = data.index(tagEnd, offsetBy: 2)
            let lengthStr = String(data[tagEnd..<lengthEnd])
            guard let length = Int(lengthStr) else { break }

            guard data.distance(from: lengthEnd, to: data.endIndex) >= length else { break }

            let valueEnd = data.index(lengthEnd, offsetBy: length)
            let value = String(data[lengthEnd..<valueEnd])

            result[tag] = value
            index = valueEnd
        }

        return result
    }

    private func buildTLV(_ tag: String, _ value: String) -> String {
        let length = String(format: "%02d", value.count)
        return "\(tag)\(length)\(value)"
    }

    private func calculateCRC(_ data: String) -> String {
        let bytes = Array(data.utf8)
        var crc: UInt16 = 0xFFFF

        for byte in bytes {
            crc ^= UInt16(byte) << 8
            for _ in 0..<8 {
                if (crc & 0x8000) != 0 {
                    crc = (crc << 1) ^ 0x1021
                } else {
                    crc = crc << 1
                }
            }
        }

        return String(format: "%04X", crc & 0xFFFF)
    }
}

// MARK: - Convenience Extensions

extension VietQR {
    /// Get formatted display information
    public var displayInfo: String {
        var info = """
        Bank BIN: \(bankBin)
        Account: \(accountNumber)
        """

        if let amount = amount {
            info += "\nAmount: \(formatAmount(amount)) VND"
        }

        if let desc = description {
            info += "\nDescription: \(desc)"
        }

        if let ref = additionalData?.reference {
            info += "\nReference: \(ref)"
        }

        return info
    }

    private func formatAmount(_ amount: String) -> String {
        guard let value = Int(amount) else { return amount }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        return formatter.string(from: NSNumber(value: value)) ?? amount
    }
}

// MARK: - Bank Directory (Optional Helper)

public struct BankInfo {
    public let bin: String
    public let shortName: String
    public let fullName: String
}

public class BankDirectory {
    public static let shared = BankDirectory()
    private init() {}

    public let banks: [String: BankInfo] = [
        "970415": BankInfo(bin: "970415", shortName: "VietinBank", fullName: "Ngân hàng TMCP Công Thương Việt Nam"),
        "970436": BankInfo(bin: "970436", shortName: "Vietcombank", fullName: "Ngân hàng TMCP Ngoại Thương Việt Nam"),
        "970418": BankInfo(bin: "970418", shortName: "BIDV", fullName: "Ngân hàng TMCP Đầu tư và Phát triển Việt Nam"),
        "970405": BankInfo(bin: "970405", shortName: "Agribank", fullName: "Ngân hàng Nông nghiệp và Phát triển Nông thôn VN"),
        "970407": BankInfo(bin: "970407", shortName: "Techcombank", fullName: "Ngân hàng TMCP Kỹ thương Việt Nam"),
        "970422": BankInfo(bin: "970422", shortName: "MB Bank", fullName: "Ngân hàng TMCP Quân đội"),
        "970416": BankInfo(bin: "970416", shortName: "ACB", fullName: "Ngân hàng TMCP Á Châu"),
        "970432": BankInfo(bin: "970432", shortName: "VPBank", fullName: "Ngân hàng TMCP Việt Nam Thịnh Vượng"),
        "970423": BankInfo(bin: "970423", shortName: "TPBank", fullName: "Ngân hàng TMCP Tiên Phong"),
        "970403": BankInfo(bin: "970403", shortName: "Sacombank", fullName: "Ngân hàng TMCP Sài Gòn Thương Tín"),
        "970454": BankInfo(bin: "970454", shortName: "BVBank", fullName: "Ngân hàng TMCP Bản Việt"),
    ]

    public func getBank(bin: String) -> BankInfo? {
        return banks[bin]
    }
}

// MARK: - Camera Scanner (Optional UI Component)

import AVFoundation

public protocol VietQRScannerDelegate: AnyObject {
    func didScanVietQR(_ vietQR: VietQR)
    func didFailScanning(error: Error)
}

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
              let vietQR = VietQRService.shared.parse(from: qrString) else {
            return
        }

        hasScanned = true
        captureSession?.stopRunning()

        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)

        delegate?.didScanVietQR(vietQR)
    }
}

// MARK: - Sample App

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
        title = "VietQR Demo"
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
            amount: amountField.text,
            description: descField.text
        )

        let qrString = VietQRService.shared.generate(from: vietQR)
        qrStringLabel.text = qrString

        if let image = VietQRService.shared.generateQRImage(from: vietQR) {
            qrImageView.image = image
            resultLabel.text = "✅ Generated:\n\n" + vietQR.displayInfo
        }
    }

    @objc private func scanTapped() {
        let scanner = VietQRScannerViewController()
        scanner.delegate = self
        let nav = UINavigationController(rootViewController: scanner)
        present(nav, animated: true)
    }

    @objc private func selectTapped() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        present(picker, animated: true)
    }

    @objc private func testTapped() {
        // Test with your sample
        let sample = "00020101021238570010A00000072701270006970436011300110018008790208QRIBFTTA530370454061000005802VN630488E4"

        if let vietQR = VietQRService.shared.parse(from: sample) {
            bankBinField.text = vietQR.bankBin
            accountField.text = vietQR.accountNumber
            amountField.text = vietQR.amount
            descField.text = vietQR.description

            resultLabel.text = "✅ Parsed:\n\n" + vietQR.displayInfo

            if let image = VietQRService.shared.generateQRImage(from: vietQR) {
                qrImageView.image = image
            }
        } else {
            showAlert("Failed to parse sample QR string")
        }
    }

    private func showAlert(_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension ViewController: VietQRScannerDelegate {
    func didScanVietQR(_ vietQR: VietQR) {
        dismiss(animated: true) {
            self.bankBinField.text = vietQR.bankBin
            self.accountField.text = vietQR.accountNumber
            self.amountField.text = vietQR.amount
            self.descField.text = vietQR.description
            self.resultLabel.text = "✅ Scanned:\n\n" + vietQR.displayInfo
        }
    }

    func didFailScanning(error: Error) {
        dismiss(animated: true) {
            self.showAlert("Scan failed: \(error.localizedDescription)")
        }
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                              didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)

        guard let image = info[.originalImage] as? UIImage,
              let vietQR = VietQRService.shared.parse(from: image) else {
            showAlert("No VietQR found in image")
            return
        }

        bankBinField.text = vietQR.bankBin
        accountField.text = vietQR.accountNumber
        amountField.text = vietQR.amount
        descField.text = vietQR.description
        resultLabel.text = "✅ Parsed from image:\n\n" + vietQR.displayInfo
    }
}

/*
USAGE EXAMPLES:

// 1. Parse from string
let qrString = "00020101021238570010A00000072701270006970436..."
if let vietQR = VietQRService.shared.parse(from: qrString) {
    print("Bank: \(vietQR.bankBin)")
    print("Account: \(vietQR.accountNumber)")
}

// 2. Generate string from object
let vietQR = VietQR(bankBin: "970436", accountNumber: "123456", amount: "10000")
let qrString = VietQRService.shared.generate(from: vietQR)

// 3. Generate QR image
if let image = VietQRService.shared.generateQRImage(from: vietQR) {
    imageView.image = image
}

// 4. Parse from image
if let vietQR = VietQRService.shared.parse(from: uiImage) {
    // Use vietQR
}

// 5. Camera scanning
let scanner = VietQRScannerViewController()
scanner.delegate = self
present(scanner, animated: true)
*/
