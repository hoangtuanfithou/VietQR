# VNBankQR - Installation Guide for Team

## 📦 Package Overview

**VNBankQR** is a Vietnamese Bank QR Code library with 3 main components:
1. **Scanner** - Universal QR scanner for all Vietnamese bank QR codes
2. **Parser** - Parse VietQR, MoMo, ZaloPay, VNPay (currently: VietQR only)
3. **Generator** - Generate QR code images

## 🚀 Installation Methods

### Method 1: Swift Package Manager (SPM) - Recommended

#### Option A: Using Xcode
1. Open your project in Xcode
2. Go to **File** > **Add Packages...**
3. Enter the repository URL: `https://github.com/yourteam/VNBankQR.git`
4. Select version/branch
5. Click **Add Package**

#### Option B: Using Package.swift
Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/yourteam/VNBankQR.git", from: "1.0.0")
],
targets: [
    .target(
        name: "YourApp",
        dependencies: ["VNBankQR"]
    )
]
```

### Method 2: Copy Sources Folder (Manual)

1. Download/clone the repository
2. Copy the `Sources/VNBankQR` folder
3. Drag it into your Xcode project
4. Make sure "Copy items if needed" is checked
5. Add to your target

### Method 3: Git Submodule

```bash
cd YourProject
git submodule add https://github.com/yourteam/VNBankQR.git Dependencies/VNBankQR
```

Then drag `Sources/VNBankQR` to your project.

## 📝 Usage

### Import

```swift
import VNBankQR
```

### 1. Scan QR Code (Part 1: Scanner)

```swift
import UIKit
import VNBankQR

class MyViewController: UIViewController {

    func scanQRCode() {
        let scanner = VNBankQR.shared.createScanner(delegate: self)
        present(scanner, animated: true)
    }
}

extension MyViewController: BankQRScannerDelegate {
    func didScanBankQR(_ qrCode: any BankQRProtocol) {
        dismiss(animated: true)

        // Handle scanned QR
        if let vietQR = qrCode as? VietQR {
            print("Bank: \(vietQR.bankBin)")
            print("Account: \(vietQR.accountNumber)")
            print("Amount: \(vietQR.amount ?? "N/A")")
        }
    }

    func didFailScanning(error: BankQRError) {
        print("Error: \(error.localizedDescription)")
    }
}
```

### 2. Parse QR Code (Part 2: Parser)

```swift
// Parse from string
let qrString = "00020101021238570010A000000727..."
if let vietQR = VNBankQR.shared.parseVietQR(qrString: qrString) {
    print("Parsed successfully!")
    print(vietQR.displayInfo)
}

// Parse from image
if let qrCode = VNBankQR.shared.parse(image: qrImage) {
    print("QR Type: \(type(of: qrCode).qrCodeType)")
}

// Auto-detect QR type
if let qrCode = VNBankQR.shared.parse(qrString: qrString) {
    switch qrCode {
    case let vietQR as VietQR:
        print("VietQR: \(vietQR.bankBin)")
    // Future:
    // case let momoQR as MoMoQR:
    //     print("MoMo: \(momoQR.phoneNumber)")
    default:
        print("Unknown QR type")
    }
}
```

### 3. Generate QR Code (Part 3: Generator)

```swift
// Create VietQR object
let vietQR = VietQR(
    bankBin: "970436",           // Vietcombank
    accountNumber: "0011001800879",
    accountName: "NGUYEN VAN A",
    amount: "100000",            // 100,000 VND
    purpose: "Payment"
)

// Generate QR image
if let qrImage = VNBankQR.shared.generateVietQRImage(from: vietQR, size: CGSize(width: 300, height: 300)) {
    imageView.image = qrImage
}

// Or generate QR string only
let qrString = VNBankQR.shared.generateVietQRString(from: vietQR)
print(qrString)
```

## 🏦 Supported Banks

VietQR currently supports 40+ Vietnamese banks:

| Bank BIN | Bank Name | Short Name |
|----------|-----------|------------|
| 970415 | Ngân hàng TMCP Công Thương Việt Nam | VietinBank |
| 970436 | Ngân hàng TMCP Ngoại Thương Việt Nam | Vietcombank |
| 970418 | Ngân hàng TMCP Đầu tư và Phát triển VN | BIDV |
| 970405 | Ngân hàng Nông nghiệp và Phát triển Nông thôn VN | Agribank |
| 970407 | Ngân hàng TMCP Kỹ thương Việt Nam | Techcombank |
| 970422 | Ngân hàng TMCP Quân đội | MB Bank |
| ... | ... | ... |

### Get Bank Info

```swift
if let bank = VietQRBankDirectory.shared.getBank(bin: "970436") {
    print("Bank: \(bank.shortName)")        // Vietcombank
    print("Full name: \(bank.fullName)")
}

// List all supported banks
let allBanks = VietQRBankDirectory.shared.getAllBanks()
print("Total banks: \(allBanks.count)")
```

## 🔧 Common Use Cases

### Use Case 1: Payment Screen

```swift
class PaymentViewController: UIViewController {
    @IBOutlet weak var qrImageView: UIImageView!

    func generatePaymentQR(amount: String, purpose: String) {
        let vietQR = VietQR(
            bankBin: currentUserBankBin,
            accountNumber: currentUserAccount,
            accountName: currentUserName,
            amount: amount,
            purpose: purpose
        )

        qrImageView.image = vietQR.generateQRImage()
    }
}
```

### Use Case 2: Scan to Pay

```swift
class ScanToPayViewController: UIViewController {
    func startScanning() {
        let scanner = VNBankQR.shared.createScanner(delegate: self)
        present(scanner, animated: true)
    }
}

extension ScanToPayViewController: BankQRScannerDelegate {
    func didScanBankQR(_ qrCode: any BankQRProtocol) {
        dismiss(animated: true)

        if let vietQR = qrCode as? VietQR {
            // Show confirmation screen
            showPaymentConfirmation(
                bankBin: vietQR.bankBin,
                account: vietQR.accountNumber,
                amount: vietQR.amount,
                purpose: vietQR.purpose
            )
        }
    }

    func didFailScanning(error: BankQRError) {
        showAlert("Scan failed: \(error.localizedDescription)")
    }
}
```

### Use Case 3: QR Gallery Scan

```swift
func scanFromGallery() {
    let picker = UIImagePickerController()
    picker.sourceType = .photoLibrary
    picker.delegate = self
    present(picker, animated: true)
}

extension MyViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                              didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)

        if let image = info[.originalImage] as? UIImage,
           let vietQR = VNBankQR.shared.parseVietQR(image: image) {
            print("Found VietQR: \(vietQR.displayInfo)")
        }
    }
}
```

## 🛠 Troubleshooting

### Issue 1: "Module 'VNBankQR' not found"
- Make sure package is added to your target
- Clean build folder (Cmd+Shift+K)
- Rebuild project

### Issue 2: Camera permission denied
Add to `Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>We need camera access to scan QR codes</string>
```

### Issue 3: SPM package not resolving
- File > Packages > Reset Package Caches
- File > Packages > Update to Latest Package Versions

## 📱 Minimum Requirements

- iOS 14.0+
- Swift 5.9+
- Xcode 15.0+

## 🔄 Future Updates

The package architecture is ready to support:
- **MoMo QR** - E-wallet QR codes
- **ZaloPay QR** - Zalo payment QR codes
- **VNPay QR** - Payment gateway QR codes

Updates will be backward compatible.

## 📞 Support

For issues or questions:
- Open issue on GitHub
- Contact: [team-email@example.com]
- Documentation: [link-to-docs]

## 📄 License

[Your License]
