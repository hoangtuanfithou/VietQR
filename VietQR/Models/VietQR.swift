// MARK: - Helper Methods

    /// Parse TLV (Tag-Length-Value) format string
    /// - Parameter data: TLV formatted string
    /// - Returns: Dictionary of tag-value pairs
    public func parseTLV(_ data: String) -> [String: String] {
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

    /// Build TLV formatted string
    /// - Parameters:
    ///   - tag: 2-character tag
    ///   - value: Value string
    /// - Returns: TLV formatted string (Tag + Length + Value)
    public func buildTLV(_ tag: String, _ value: String) -> String {
        let length = String(format: "%02d", value.count)
        return "\(tag)\(length)\(value)"
    }

    /// Calculate CRC-16/CCITT-FALSE checksum
    /// - Parameter data: Data string including "6304" but excluding CRC value
    /// - Returns: 4-character hex CRC value
    public func calculateCRC(_ data: String) -> String {
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
    }// MARK: - VietQR Core Library
// File: VietQR.swift
// Based on official NAPAS VietQR specification v1.0 (September 2021)

import Foundation
import UIKit
import CoreImage

// MARK: - Models

/// VietQR data model following EMV QCO specification and NAPAS VietQR standard
public struct VietQR {
    // Merchant Account Information (Tag 38)
    public var bankBin: String              // Acquirer/BNB ID (6 digits)
    public var accountNumber: String        // Consumer ID / Account Number
    public var accountName: String?         // Merchant Name (Tag 59)
    public var amount: String?              // Transaction Amount (Tag 54)
    public var purpose: String?             // Purpose of Transaction (Tag 62-08)

    // Service codes
    public var serviceCode: String = "QRIBFTTA"  // QRIBFTTA (account) or QRIBFTTC (card)

    // Additional data from Tag 62
    public var additionalData: AdditionalData?

    public struct AdditionalData {
        public var billNumber: String?          // Tag 62-01
        public var mobileNumber: String?        // Tag 62-02
        public var store: String?               // Tag 62-03
        public var loyaltyNumber: String?       // Tag 62-04
        public var reference: String?           // Tag 62-05
        public var customerLabel: String?       // Tag 62-06
        public var terminal: String?            // Tag 62-07
        public var purpose: String?             // Tag 62-08

        public init(billNumber: String? = nil, mobileNumber: String? = nil, store: String? = nil,
                    loyaltyNumber: String? = nil, reference: String? = nil, customerLabel: String? = nil,
                    terminal: String? = nil, purpose: String? = nil) {
            self.billNumber = billNumber
            self.mobileNumber = mobileNumber
            self.store = store
            self.loyaltyNumber = loyaltyNumber
            self.reference = reference
            self.customerLabel = customerLabel
            self.terminal = terminal
            self.purpose = purpose
        }
    }

    public init(bankBin: String, accountNumber: String, accountName: String? = nil,
                amount: String? = nil, purpose: String? = nil) {
        self.bankBin = bankBin
        self.accountNumber = accountNumber
        self.accountName = accountName
        self.amount = amount
        self.purpose = purpose

        if let purpose = purpose {
            self.additionalData = AdditionalData(purpose: purpose)
        }
    }
}

// MARK: - VietQR Parser & Generator

public class VietQRService {
    public static let shared = VietQRService()
    private init() {}

    private let GUID = "A000000727"  // NAPAS AID

    // MARK: - Parse from String

    /// Parse VietQR from EMV QCO string format
    /// Example: "00020101021238570010A00000072701270006970436011300110018008790208QRIBFTTA530370454061000005802VN62130809nhan tien6304D1EF"
    /// - Parameter qrString: EMV format string
    /// - Returns: VietQR object or nil if parsing fails
    public func parse(from qrString: String) -> VietQR? {
        let fields = parseTLV(qrString)

        // Validate payload format indicator (Tag 00 = "01")
        guard fields["00"] == "01" else { return nil }

        // Parse merchant account information (Tag 38 for VietQR)
        guard let merchantInfo = fields["38"] else { return nil }
        let merchantFields = parseTLV(merchantInfo)

        // Validate GUID (Tag 00 = "A000000727")
        guard merchantFields["00"] == GUID else { return nil }

        // Parse BNB structure (Tag 01)
        guard let bnbInfo = merchantFields["01"] else { return nil }
        let bnbFields = parseTLV(bnbInfo)

        // Extract Bank BIN (Tag 00) and Account Number (Tag 01)
        guard let bankBin = bnbFields["00"],
              let accountNumber = bnbFields["01"] else {
            return nil
        }

        // Service code (Tag 02)
        let serviceCode = merchantFields["02"] ?? "QRIBFTTA"

        // Transaction amount (Tag 54)
        // Transaction amount (Tag 54)
        let amount = fields["54"]

        // Merchant name / Account name (Tag 59)
        let accountName = fields["59"]

        // Parse additional data (Tag 62)
        var purpose: String? = nil
        var additionalData: VietQR.AdditionalData? = nil

        if let additionalInfo = fields["62"] {
            let additionalFields = parseTLV(additionalInfo)

            var data = VietQR.AdditionalData()
            data.billNumber = additionalFields["01"]
            data.mobileNumber = additionalFields["02"]
            data.store = additionalFields["03"]
            data.loyaltyNumber = additionalFields["04"]
            data.reference = additionalFields["05"]
            data.customerLabel = additionalFields["06"]
            data.terminal = additionalFields["07"]
            data.purpose = additionalFields["08"]

            additionalData = data
            purpose = data.purpose
        }

        var vietQR = VietQR(
            bankBin: bankBin,
            accountNumber: accountNumber,
            accountName: accountName,
            amount: amount,
            purpose: purpose
        )

        vietQR.serviceCode = serviceCode
        vietQR.additionalData = additionalData

        return vietQR
    }

    // MARK: - Generate String

    /// Generate EMV QCO string from VietQR object
    /// - Parameter vietQR: VietQR object
    /// - Returns: EMV format string compliant with NAPAS VietQR spec
    public func generate(from vietQR: VietQR) -> String {
        var result = ""

        // 00: Payload Format Indicator
        result += buildTLV("00", "01")

        // 01: Point of Initiation Method (11 = static, 12 = dynamic)
        let isStatic = vietQR.amount == nil || vietQR.amount?.isEmpty == true
        result += buildTLV("01", isStatic ? "11" : "12")

        // 38: Merchant Account Information (VietQR)
        // Structure: Tag 38 contains nested TLV
        //   - Tag 00: GUID (A000000727)
        //   - Tag 01: BNB structure
        //     - Tag 00: Bank BIN (6 digits)
        //     - Tag 01: Account Number
        //   - Tag 02: Service Code (QRIBFTTA or QRIBFTTC)

        var bnbInfo = ""
        bnbInfo += buildTLV("00", vietQR.bankBin)
        bnbInfo += buildTLV("01", vietQR.accountNumber)

        var merchantInfo = ""
        merchantInfo += buildTLV("00", GUID)
        merchantInfo += buildTLV("01", bnbInfo)
        merchantInfo += buildTLV("02", vietQR.serviceCode)

        result += buildTLV("38", merchantInfo)

        // 53: Transaction Currency (704 = VND)
        result += buildTLV("53", "704")

        // 54: Transaction Amount (optional)
        if let amount = vietQR.amount, !amount.isEmpty {
            result += buildTLV("54", amount)
        }

        // 58: Country Code
        result += buildTLV("58", "VN")

        // 59: Merchant Name (Account Name) - optional
        if let accountName = vietQR.accountName, !accountName.isEmpty {
            result += buildTLV("59", accountName)
        }

        // 62: Additional Data (optional)
        if let additional = vietQR.additionalData {
            var additionalStr = ""

            if let billNumber = additional.billNumber, !billNumber.isEmpty {
                additionalStr += buildTLV("01", billNumber)
            }
            if let mobile = additional.mobileNumber, !mobile.isEmpty {
                additionalStr += buildTLV("02", mobile)
            }
            if let store = additional.store, !store.isEmpty {
                additionalStr += buildTLV("03", store)
            }
            if let loyalty = additional.loyaltyNumber, !loyalty.isEmpty {
                additionalStr += buildTLV("04", loyalty)
            }
            if let reference = additional.reference, !reference.isEmpty {
                additionalStr += buildTLV("05", reference)
            }
            if let customer = additional.customerLabel, !customer.isEmpty {
                additionalStr += buildTLV("06", customer)
            }
            if let terminal = additional.terminal, !terminal.isEmpty {
                additionalStr += buildTLV("07", terminal)
            }
            if let purpose = additional.purpose, !purpose.isEmpty {
                additionalStr += buildTLV("08", purpose)
            }

            if !additionalStr.isEmpty {
                result += buildTLV("62", additionalStr)
            }
        } else if let purpose = vietQR.purpose, !purpose.isEmpty {
            // If no additionalData but purpose exists, create it
            let additionalStr = buildTLV("08", purpose)
            result += buildTLV("62", additionalStr)
        }

        // 63: CRC (always last) - ISO/IEC 13239 using polynomial '1021' (hex) and initial value 'FFFF' (hex)
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

        if let accountName = accountName {
            info += "\nAccount Name: \(accountName)"
        }

        if let amount = amount {
            info += "\nAmount: \(formatAmount(amount)) VND"
        }

        if let purpose = purpose {
            info += "\nPurpose: \(purpose)"
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
            accountName: nil,
            amount: amountField.text,
            purpose: descField.text
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
        // Test with your actual sample from NAPAS spec
        let sample = "00020101021238570010A00000072701270006970436011300110018008790208QRIBFTTA530370454061000005802VN62130809nhan tien6304D1EF"

        print("=== Testing VietQR Parser ===")
        print("Input: \(sample)")
        print("")

        if let vietQR = VietQRService.shared.parse(from: sample) {
            print("✅ Parsed Successfully!")
            print("")
            print("Bank BIN: \(vietQR.bankBin)")
            print("Account Number: \(vietQR.accountNumber)")
            print("Account Name: \(vietQR.accountName ?? "N/A")")
            print("Amount: \(vietQR.amount ?? "N/A")")
            print("Purpose: \(vietQR.purpose ?? "N/A")")
            print("Service Code: \(vietQR.serviceCode)")

            // Verify bank
            if let bank = BankDirectory.shared.getBank(bin: vietQR.bankBin) {
                print("Bank Name: \(bank.shortName)")
            }

            // Update UI
            bankBinField.text = vietQR.bankBin
            accountField.text = vietQR.accountNumber
            amountField.text = vietQR.amount
            descField.text = vietQR.purpose

            resultLabel.text = "✅ Parsed from sample:\n\n" + vietQR.displayInfo

            // Generate QR image to verify round-trip
            if let image = VietQRService.shared.generateQRImage(from: vietQR) {
                qrImageView.image = image

                // Test regeneration
                let regenerated = VietQRService.shared.generate(from: vietQR)
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

extension ViewController: VietQRScannerDelegate {
    func didScanVietQR(_ vietQR: VietQR) {
        dismiss(animated: true) {
            self.bankBinField.text = vietQR.bankBin
            self.accountField.text = vietQR.accountNumber
            self.amountField.text = vietQR.amount
            self.descField.text = vietQR.purpose
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
        descField.text = vietQR.purpose
        resultLabel.text = "✅ Parsed from image:\n\n" + vietQR.displayInfo
    }
}

/*
USAGE EXAMPLES:

// 1. Parse from string
let qrString = "00020101021238570010A00000072701270006970436011300110018008790208QRIBFTTA530370454061000005802VN62130809nhan tien6304D1EF"
if let vietQR = VietQRService.shared.parse(from: qrString) {
    print("Bank BIN: \(vietQR.bankBin)")              // 970436
    print("Account Number: \(vietQR.accountNumber)")   // 0011001800879
    print("Account Name: \(vietQR.accountName ?? "")")  // NGUYEN HOANG TUAN (if available in tag 59)
    print("Amount: \(vietQR.amount ?? "")")            // 100000
    print("Purpose: \(vietQR.purpose ?? "")")          // nhan tien
}

// 2. Generate string from object
let vietQR = VietQR(
    bankBin: "970436",
    accountNumber: "0011001800879",
    accountName: "NGUYEN HOANG TUAN",
    amount: "100000",
    purpose: "nhan tien"
)
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
