//
//  ScannerExamplesViewController.swift
//  VNBankQRDemo
//
//  Demo showing different scanner overlay configurations
//

import UIKit
import AVFoundation
import VNBankQR

class ScannerExamplesViewController: UIViewController {

    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private let resultLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        title = "Scanner Examples"
        view.backgroundColor = .systemBackground

        // ScrollView
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        // StackView
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)

        // Add example buttons
        addExampleButton(title: "1. Default Scanner", subtitle: "Basic scanner with default overlay", action: #selector(example1DefaultScanner))
        addExampleButton(title: "2. Custom Configuration", subtitle: "Customize colors and sizes", action: #selector(example2CustomConfig))
        addExampleButton(title: "3. UIView Overlay", subtitle: "Simple custom overlay", action: #selector(example3CustomViewOverlay))
        addExampleButton(title: "4. LPBank Overlay", subtitle: "Production-ready custom ViewController", action: #selector(example4LPBankOverlay))

        // Result label
        resultLabel.numberOfLines = 0
        resultLabel.textAlignment = .left
        resultLabel.font = .systemFont(ofSize: 14)
        stackView.addArrangedSubview(resultLabel)

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
    }

    private func addExampleButton(title: String, subtitle: String, action: Selector) {
        let container = UIView()
        container.backgroundColor = .secondarySystemBackground
        container.layer.cornerRadius = 12

        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.contentHorizontalAlignment = .left
        button.addTarget(self, action: action, for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(button)

        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.font = .systemFont(ofSize: 14)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(subtitleLabel)

        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            button.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            button.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),

            subtitleLabel.topAnchor.constraint(equalTo: button.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: button.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: button.trailingAnchor),
            subtitleLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12),

            container.heightAnchor.constraint(greaterThanOrEqualToConstant: 70)
        ])

        stackView.addArrangedSubview(container)
    }

    // MARK: - Scanner Examples

    @objc private func example1DefaultScanner() {
        let scanner = VNBankQR.shared.createScanner(delegate: self)
        present(scanner, animated: true)
    }

    @objc private func example2CustomConfig() {
        let config = ScannerConfiguration(
            scanAreaSize: 280,
            scanAreaCornerRadius: 16,
            overlayColor: UIColor.black.withAlphaComponent(0.6),
            scanAreaBorderColor: .systemGreen,
            scanAreaBorderWidth: 3
        )
        let scanner = VNBankQR.shared.createScanner(delegate: self, configuration: config)
        present(scanner, animated: true)
    }

    @objc private func example3CustomViewOverlay() {
        let customOverlay = createCustomOverlay()
        let config = ScannerConfiguration(customOverlay: customOverlay)
        let scanner = VNBankQR.shared.createScanner(delegate: self, configuration: config)
        present(scanner, animated: true)
    }

    @objc private func example4LPBankOverlay() {
        let overlayVC = LPBankScannerOverlay()
        let config = ScannerConfiguration(customOverlayViewController: overlayVC)
        let scanner = VNBankQR.shared.createScanner(delegate: self, configuration: config)
        present(scanner, animated: true)
    }

    // MARK: - Custom Overlay Example

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

            // Top
            if sides[0] {
                let top = UIView(frame: CGRect(x: 0, y: 0, width: cornerLength, height: cornerWidth))
                top.backgroundColor = .systemGreen
                corner.addSubview(top)
            }

            // Right
            if sides[1] {
                let right = UIView(frame: CGRect(x: cornerLength - cornerWidth, y: 0, width: cornerWidth, height: cornerLength))
                right.backgroundColor = .systemGreen
                corner.addSubview(right)
            }

            // Bottom
            if sides[2] {
                let bottom = UIView(frame: CGRect(x: 0, y: cornerLength - cornerWidth, width: cornerLength, height: cornerWidth))
                bottom.backgroundColor = .systemGreen
                corner.addSubview(bottom)
            }

            // Left
            if sides[3] {
                let left = UIView(frame: CGRect(x: 0, y: 0, width: cornerWidth, height: cornerLength))
                left.backgroundColor = .systemGreen
                corner.addSubview(left)
            }

            scanFrame.addSubview(corner)
        }

        return overlay
    }
}

// MARK: - BankQRScannerDelegate

extension ScannerExamplesViewController: BankQRScannerDelegate {
    func didScanBankQR(_ qrCode: any BankQRProtocol) {
        dismiss(animated: true) {
            if let vietQR = qrCode as? VietQR {
                self.resultLabel.text = "✅ Scanned VietQR:\n\n" + vietQR.displayInfo
            } else {
                self.resultLabel.text = "✅ Scanned: \(qrCode.displayInfo)"
            }
        }
    }

    func didFailScanning(error: BankQRError) {
        dismiss(animated: true) {
            self.resultLabel.text = "❌ Error: \(error)"
        }
    }
}
