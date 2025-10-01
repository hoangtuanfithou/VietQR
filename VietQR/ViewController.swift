////
////  ViewController.swift
////  VietQR
////
////  Created by admin on 30/9/25.
////
//
//import UIKit
//import AVFoundation
//
//final class ViewController2: UIViewController {
//    private let bankBinTextField = UITextField()
//    private let accountNumberTextField = UITextField()
//    private let amountTextField = UITextField()
//    private let descriptionTextField = UITextField()
//    private let accountNameTextField = UITextField()
//    private let qrImageView = UIImageView()
//    private let resultLabel = UILabel()
//    private let generateButton = UIButton(type: .system)
//    private let scanButton = UIButton(type: .system)
//    private let selectImageButton = UIButton(type: .system)
//
//    private let scrollView = UIScrollView()
//    private let contentView = UIView()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupUI()
//        setupConstraints()
//        setupDefaultValues()
//    }
//
//    private func setupUI() {
//        title = "VietQR Sample App"
//        view.backgroundColor = .systemBackground
//
//        // Setup ScrollView
//        scrollView.translatesAutoresizingMaskIntoConstraints = false
//        contentView.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(scrollView)
//        scrollView.addSubview(contentView)
//
//        // Setup Text Fields
//        setupTextField(bankBinTextField, placeholder: "Bank BIN")
//        setupTextField(accountNumberTextField, placeholder: "Account Number")
//        setupTextField(amountTextField, placeholder: "Amount (optional)")
//        setupTextField(descriptionTextField, placeholder: "Description (optional)")
//        setupTextField(accountNameTextField, placeholder: "Account Name (optional)")
//
//        // Setup QR ImageView
//        qrImageView.translatesAutoresizingMaskIntoConstraints = false
//        qrImageView.layer.borderWidth = 1
//        qrImageView.layer.borderColor = UIColor.lightGray.cgColor
//        qrImageView.contentMode = .scaleAspectFit
//        qrImageView.backgroundColor = .systemGray6
//        contentView.addSubview(qrImageView)
//
//        // Setup Buttons
//        setupButton(generateButton, title: "Generate QR Code", action: #selector(generateQRCode))
//        setupButton(scanButton, title: "Scan QR Code", action: #selector(scanQRCode))
//        setupButton(selectImageButton, title: "Select Image to Scan", action: #selector(selectImageForScanning))
//
//        // Setup Result Label
//        resultLabel.translatesAutoresizingMaskIntoConstraints = false
//        resultLabel.numberOfLines = 0
//        resultLabel.textColor = .systemGreen
//        resultLabel.font = .systemFont(ofSize: 14)
//        resultLabel.textAlignment = .center
//        contentView.addSubview(resultLabel)
//    }
//
//    private func setupTextField(_ textField: UITextField, placeholder: String) {
//        textField.translatesAutoresizingMaskIntoConstraints = false
//        textField.placeholder = placeholder
//        textField.layer.borderWidth = 1
//        textField.layer.borderColor = UIColor.lightGray.cgColor
//        textField.layer.cornerRadius = 8
//        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
//        textField.leftViewMode = .always
//        textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
//        textField.rightViewMode = .always
//        textField.autocapitalizationType = .none
//        contentView.addSubview(textField)
//    }
//
//    private func setupButton(_ button: UIButton, title: String, action: Selector) {
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.setTitle(title, for: .normal)
//        button.backgroundColor = .systemBlue
//        button.setTitleColor(.white, for: .normal)
//        button.layer.cornerRadius = 8
//        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
//        button.addTarget(self, action: action, for: .touchUpInside)
//        contentView.addSubview(button)
//    }
//
//    private func setupConstraints() {
//        NSLayoutConstraint.activate([
//            // ScrollView
//            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//
//            // ContentView
//            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
//            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
//            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
//            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
//            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
//
//            // Bank BIN TextField
//            bankBinTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
//            bankBinTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
//            bankBinTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
//            bankBinTextField.heightAnchor.constraint(equalToConstant: 44),
//
//            // Account Number TextField
//            accountNumberTextField.topAnchor.constraint(equalTo: bankBinTextField.bottomAnchor, constant: 12),
//            accountNumberTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
//            accountNumberTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
//            accountNumberTextField.heightAnchor.constraint(equalToConstant: 44),
//
//            // Amount TextField
//            amountTextField.topAnchor.constraint(equalTo: accountNumberTextField.bottomAnchor, constant: 12),
//            amountTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
//            amountTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
//            amountTextField.heightAnchor.constraint(equalToConstant: 44),
//
//            // Description TextField
//            descriptionTextField.topAnchor.constraint(equalTo: amountTextField.bottomAnchor, constant: 12),
//            descriptionTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
//            descriptionTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
//            descriptionTextField.heightAnchor.constraint(equalToConstant: 44),
//
//            // Account Name TextField
//            accountNameTextField.topAnchor.constraint(equalTo: descriptionTextField.bottomAnchor, constant: 12),
//            accountNameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
//            accountNameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
//            accountNameTextField.heightAnchor.constraint(equalToConstant: 44),
//
//            // Generate Button
//            generateButton.topAnchor.constraint(equalTo: accountNameTextField.bottomAnchor, constant: 24),
//            generateButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
//            generateButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
//            generateButton.heightAnchor.constraint(equalToConstant: 50),
//
//            // QR ImageView
//            qrImageView.topAnchor.constraint(equalTo: generateButton.bottomAnchor, constant: 24),
//            qrImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
//            qrImageView.widthAnchor.constraint(equalToConstant: 250),
//            qrImageView.heightAnchor.constraint(equalToConstant: 250),
//
//            // Scan Button
//            scanButton.topAnchor.constraint(equalTo: qrImageView.bottomAnchor, constant: 24),
//            scanButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
//            scanButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
//            scanButton.heightAnchor.constraint(equalToConstant: 50),
//
//            // Select Image Button
//            selectImageButton.topAnchor.constraint(equalTo: scanButton.bottomAnchor, constant: 12),
//            selectImageButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
//            selectImageButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
//            selectImageButton.heightAnchor.constraint(equalToConstant: 50),
//
//            // Result Label
//            resultLabel.topAnchor.constraint(equalTo: selectImageButton.bottomAnchor, constant: 24),
//            resultLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
//            resultLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
//            resultLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
//        ])
//    }
//
//    private func setupDefaultValues() {
//        bankBinTextField.text = "970415" // VietinBank
//        accountNumberTextField.text = "1234567890"
//        amountTextField.text = "100000"
//        descriptionTextField.text = "Test payment"
//        accountNameTextField.text = "NGUYEN VAN A"
//    }
//
//    @objc private func generateQRCode() {
//        guard let bankBin = bankBinTextField.text, !bankBin.isEmpty,
//              let accountNumber = accountNumberTextField.text, !accountNumber.isEmpty else {
//            showAlert(title: "Error", message: "Bank BIN and Account Number are required")
//            return
//        }
//
//        let vietQR = VietQR(
//            bankBin: bankBin,
//            accountNumber: accountNumber,
//            amount: amountTextField.text,
//            description: descriptionTextField.text,
//            accountName: accountNameTextField.text
//        )
//
//        if let qrImage = VietQRManager.shared.generateQRImage(from: vietQR, size: CGSize(width: 300, height: 300)) {
//            qrImageView.image = qrImage
//            resultLabel.text = "QR Code generated successfully!\n\nData: \(vietQR.toQRString())"
//        } else {
//            showAlert(title: "Error", message: "Failed to generate QR code")
//        }
//    }
//
//    @objc private func scanQRCode() {
//        let scannerVC = VietQRScannerViewController()
//        scannerVC.delegate = self
//        let navVC = UINavigationController(rootViewController: scannerVC)
//        present(navVC, animated: true)
//    }
//
//    @objc private func selectImageForScanning() {
//        let picker = UIImagePickerController()
//        picker.sourceType = .photoLibrary
//        picker.delegate = self
//        present(picker, animated: true)
//    }
//
//    private func updateUIWithVietQR(_ vietQR: VietQR) {
//        bankBinTextField.text = vietQR.bankBin
//        accountNumberTextField.text = vietQR.accountNumber
//        amountTextField.text = vietQR.amount
//        descriptionTextField.text = vietQR.description
//        accountNameTextField.text = vietQR.accountName
//
//        resultLabel.text = "Scanned VietQR successfully!\n\nData: \(vietQR.toQRString())"
//    }
//
//    private func showAlert(title: String, message: String) {
//        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "OK", style: .default))
//        present(alert, animated: true)
//    }
//}
//
//// MARK: - Extensions
//
//extension ViewController2: VietQRScannerDelegate {
//    func didScanVietQR(_ vietQR: VietQR) {
//        dismiss(animated: true) {
//            self.updateUIWithVietQR(vietQR)
//        }
//    }
//
//    func didFailWithError(_ error: VietQRError) {
//        dismiss(animated: true) {
//            self.showAlert(title: "Scan Error", message: error.localizedDescription)
//        }
//    }
//}
//
//extension ViewController2: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        picker.dismiss(animated: true)
//
//        guard let image = info[.originalImage] as? UIImage else { return }
//
//        let result = VietQRManager.shared.parseVietQR(from: image)
//        switch result {
//        case .success(let vietQR):
//            updateUIWithVietQR(vietQR)
//        case .failure(let error):
//            showAlert(title: "Parse Error", message: error.localizedDescription)
//        }
//    }
//}
//
//extension VietQRError: LocalizedError {
//    public var errorDescription: String? {
//        switch self {
//        case .invalidQRCode:
//            return "Invalid QR code format"
//        case .cameraNotAvailable:
//            return "Camera not available"
//        case .generationFailed:
//            return "Failed to generate QR code"
//        case .parsingFailed:
//            return "Failed to parse VietQR data"
//        }
//    }
//}
