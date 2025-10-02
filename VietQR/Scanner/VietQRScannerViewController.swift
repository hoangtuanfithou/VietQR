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


// MARK: - Camera Scanner (Optional UI Component)
//
//import UIKit
//import AVFoundation
//
//public protocol VietQRScannerDelegate: AnyObject {
//    func didScanVietQR(_ vietQR: VietQR)
//    func didFailScanning(error: Error)
//}
//
//public class VietQRScannerViewController: UIViewController {
//    public weak var delegate: VietQRScannerDelegate?
//
//    private var captureSession: AVCaptureSession?
//    private var previewLayer: AVCaptureVideoPreviewLayer?
//    private var hasScanned = false
//
//    public override func viewDidLoad() {
//        super.viewDidLoad()
//        setupCamera()
//        setupUI()
//    }
//
//    private func setupCamera() {
//        guard let device = AVCaptureDevice.default(for: .video) else { return }
//
//        do {
//            let input = try AVCaptureDeviceInput(device: device)
//            let session = AVCaptureSession()
//            session.addInput(input)
//
//            let output = AVCaptureMetadataOutput()
//            session.addOutput(output)
//            output.setMetadataObjectsDelegate(self, queue: .main)
//            output.metadataObjectTypes = [.qr]
//
//            self.captureSession = session
//        } catch {
//            delegate?.didFailScanning(error: error)
//        }
//    }
//
//    private func setupUI() {
//        guard let session = captureSession else { return }
//
//        view.backgroundColor = .black
//        title = "Scan VietQR"
//
//        let preview = AVCaptureVideoPreviewLayer(session: session)
//        preview.frame = view.bounds
//        preview.videoGravity = .resizeAspectFill
//        view.layer.addSublayer(preview)
//        previewLayer = preview
//
//        navigationItem.rightBarButtonItem = UIBarButtonItem(
//            barButtonSystemItem: .cancel,
//            target: self,
//            action: #selector(cancelTapped)
//        )
//
//        session.startRunning()
//    }
//
//    @objc private func cancelTapped() {
//        captureSession?.stopRunning()
//        dismiss(animated: true)
//    }
//
//    public override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        previewLayer?.frame = view.bounds
//    }
//}
//
//extension VietQRScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
//    public func metadataOutput(_ output: AVCaptureMetadataOutput,
//                              didOutput metadataObjects: [AVMetadataObject],
//                              from connection: AVCaptureConnection) {
//        guard !hasScanned,
//              let metadata = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
//              let qrString = metadata.stringValue,
//              let vietQR = VietQRService.shared.parse(from: qrString) else {
//            return
//        }
//
//        hasScanned = true
//        captureSession?.stopRunning()
//
//        let generator = UINotificationFeedbackGenerator()
//        generator.notificationOccurred(.success)
//
//        delegate?.didScanVietQR(vietQR)
//    }
//}
//
//// MARK: - Sample App
//
//class ViewController: UIViewController {
//
//    private let scrollView = UIScrollView()
//    private let stackView = UIStackView()
//
//    private let bankBinField = UITextField()
//    private let accountField = UITextField()
//    private let amountField = UITextField()
//    private let descField = UITextField()
//
//    private let qrImageView = UIImageView()
//    private let qrStringLabel = UILabel()
//    private let resultLabel = UILabel()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupUI()
//        setupDemo()
//    }
//
//    private func setupUI() {
//        title = "VietQR Demo"
//        view.backgroundColor = .systemBackground
//
//        // ScrollView
//        scrollView.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(scrollView)
//
//        // StackView
//        stackView.axis = .vertical
//        stackView.spacing = 16
//        stackView.translatesAutoresizingMaskIntoConstraints = false
//        scrollView.addSubview(stackView)
//
//        // Input fields
//        [bankBinField, accountField, amountField, descField].forEach { field in
//            field.borderStyle = .roundedRect
//            field.autocorrectionType = .no
//            field.autocapitalizationType = .none
//            stackView.addArrangedSubview(field)
//        }
//
//        bankBinField.placeholder = "Bank BIN (6 digits)"
//        bankBinField.keyboardType = .numberPad
//        accountField.placeholder = "Account Number"
//        amountField.placeholder = "Amount (optional)"
//        amountField.keyboardType = .numberPad
//        descField.placeholder = "Description (optional)"
//
//        // Generate button
//        let generateBtn = UIButton(type: .system)
//        generateBtn.setTitle("Generate QR Code", for: .normal)
//        generateBtn.backgroundColor = .systemBlue
//        generateBtn.setTitleColor(.white, for: .normal)
//        generateBtn.layer.cornerRadius = 12
//        generateBtn.heightAnchor.constraint(equalToConstant: 50).isActive = true
//        generateBtn.addTarget(self, action: #selector(generateTapped), for: .touchUpInside)
//        stackView.addArrangedSubview(generateBtn)
//
//        // QR Image
//        qrImageView.contentMode = .scaleAspectFit
//        qrImageView.backgroundColor = .white
//        qrImageView.layer.borderWidth = 1
//        qrImageView.layer.borderColor = UIColor.systemGray4.cgColor
//        qrImageView.heightAnchor.constraint(equalToConstant: 300).isActive = true
//        stackView.addArrangedSubview(qrImageView)
//
//        // QR String
//        qrStringLabel.font = .monospacedSystemFont(ofSize: 8, weight: .regular)
//        qrStringLabel.numberOfLines = 0
//        qrStringLabel.textColor = .systemGray
//        stackView.addArrangedSubview(qrStringLabel)
//
//        // Action buttons
//        let scanBtn = createButton(title: "📷 Scan QR", action: #selector(scanTapped))
//        let selectBtn = createButton(title: "🖼 Select Image", action: #selector(selectTapped))
//        let testBtn = createButton(title: "🧪 Test Parse", action: #selector(testTapped))
//
//        [scanBtn, selectBtn, testBtn].forEach { stackView.addArrangedSubview($0) }
//
//        // Result
//        resultLabel.font = .systemFont(ofSize: 14)
//        resultLabel.numberOfLines = 0
//        stackView.addArrangedSubview(resultLabel)
//
//        // Constraints
//        NSLayoutConstraint.activate([
//            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//
//            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
//            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
//            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
//            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
//            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
//        ])
//
//        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
//        view.addGestureRecognizer(tap)
//    }
//
//    private func createButton(title: String, action: Selector) -> UIButton {
//        let btn = UIButton(type: .system)
//        btn.setTitle(title, for: .normal)
//        btn.backgroundColor = .systemGray5
//        btn.setTitleColor(.label, for: .normal)
//        btn.layer.cornerRadius = 12
//        btn.heightAnchor.constraint(equalToConstant: 50).isActive = true
//        btn.addTarget(self, action: action, for: .touchUpInside)
//        return btn
//    }
//
//    private func setupDemo() {
//        bankBinField.text = "970436"
//        accountField.text = "0011001800879"
//        amountField.text = "10000"
//        descField.text = "QRIBFTTA"
//    }
//
//    @objc private func generateTapped() {
//        guard let bin = bankBinField.text, !bin.isEmpty,
//              let account = accountField.text, !account.isEmpty else {
//            showAlert("Please enter Bank BIN and Account Number")
//            return
//        }
//
//        let vietQR = VietQR(
//            bankBin: bin,
//            accountNumber: account,
//            amount: amountField.text,
//            description: descField.text
//        )
//
//        let qrString = VietQRService.shared.generate(from: vietQR)
//        qrStringLabel.text = qrString
//
//        if let image = VietQRService.shared.generateQRImage(from: vietQR) {
//            qrImageView.image = image
//            resultLabel.text = "✅ Generated:\n\n" + vietQR.displayInfo
//        }
//    }
//
//    @objc private func scanTapped() {
//        let scanner = VietQRScannerViewController()
//        scanner.delegate = self
//        let nav = UINavigationController(rootViewController: scanner)
//        present(nav, animated: true)
//    }
//
//    @objc private func selectTapped() {
//        let picker = UIImagePickerController()
//        picker.sourceType = .photoLibrary
//        picker.delegate = self
//        present(picker, animated: true)
//    }
//
//    @objc private func testTapped() {
//        // Test with your sample
//        let sample = "00020101021238570010A00000072701270006970436011300110018008790208QRIBFTTA530370454061000005802VN62130809nhan tien6304D1EF"
//
//        if let vietQR = VietQRService.shared.parse(from: sample) {
//            bankBinField.text = vietQR.bankBin
//            accountField.text = vietQR.accountNumber
//            amountField.text = vietQR.amount
//            descField.text = vietQR.description
//
//            resultLabel.text = "✅ Parsed:\n\n" + vietQR.displayInfo
//
//            if let image = VietQRService.shared.generateQRImage(from: vietQR) {
//                qrImageView.image = image
//            }
//        } else {
//            showAlert("Failed to parse sample QR string")
//        }
//    }
//
//    private func showAlert(_ message: String) {
//        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "OK", style: .default))
//        present(alert, animated: true)
//    }
//}
//
//extension ViewController: VietQRScannerDelegate {
//    func didScanVietQR(_ vietQR: VietQR) {
//        dismiss(animated: true) {
//            self.bankBinField.text = vietQR.bankBin
//            self.accountField.text = vietQR.accountNumber
//            self.amountField.text = vietQR.amount
//            self.descField.text = vietQR.description
//            self.resultLabel.text = "✅ Scanned:\n\n" + vietQR.displayInfo
//        }
//    }
//
//    func didFailScanning(error: Error) {
//        dismiss(animated: true) {
//            self.showAlert("Scan failed: \(error.localizedDescription)")
//        }
//    }
//}
//
//extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//    func imagePickerController(_ picker: UIImagePickerController,
//                              didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        picker.dismiss(animated: true)
//
//        guard let image = info[.originalImage] as? UIImage,
//              let vietQR = VietQRService.shared.parse(from: image) else {
//            showAlert("No VietQR found in image")
//            return
//        }
//
//        bankBinField.text = vietQR.bankBin
//        accountField.text = vietQR.accountNumber
//        amountField.text = vietQR.amount
//        descField.text = vietQR.description
//        resultLabel.text = "✅ Parsed from image:\n\n" + vietQR.displayInfo
//    }
//}

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
