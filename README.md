# VNBankQR 🇻🇳

**Vietnamese Bank QR Code Scanner, Parser & Generator**

A comprehensive Swift package for scanning, parsing, and generating Vietnamese bank QR codes. Currently supports VietQR with architecture ready for MoMo, ZaloPay, and VNPay.

[![Swift Version](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-iOS%2014+-lightgrey.svg)](https://www.apple.com/ios)
[![SPM](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)](https://swift.org/package-manager)

## Features

### ✅ Currently Supported
- **VietQR** - NAPAS VietQR standard (40+ Vietnamese banks)
  - Parse QR codes from string or image
  - Generate QR codes with bank info
  - Support for static and dynamic QR
  - Transaction amount, purpose, additional data
  - Bank directory lookup

### 🔜 Coming Soon
- **MoMo QR** - Vietnam's largest e-wallet (31M+ users)
- **ZaloPay QR** - Zalo ecosystem integration
- **VNPay QR** - Payment gateway QR codes

## Architecture

The package is organized into 3 main components:

### Part 1: Scanner 📷
Universal QR scanner that works with all Vietnamese bank QR codes
- Auto-detects QR type (VietQR, MoMo, ZaloPay, VNPay)
- Camera-based scanning
- Image-based scanning

### Part 2: Parser 🔍
Parse Vietnamese bank QR codes
- VietQR parser (EMVCo + NAPAS standard)
- Auto-detection factory
- Extensible for future QR types

### Part 3: Generator 🎨
Generate QR code images
- VietQR generation
- Customizable QR size
- High error correction

## Installation

### Swift Package Manager (Recommended)

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/yourteam/VNBankQR.git", from: "1.0.0")
]
```

Or in Xcode:
1. File > Add Packages
2. Enter repository URL
3. Select version/branch

### Manual Installation

1. Copy the `Sources/VNBankQR` folder to your project
2. Add all files to your target

## Quick Start

### 1. Import

```swift
import VNBankQR
```

### 2. Parse QR Code

```swift
// From string
let qrString = "00020101021238570010A000000727..."
if let qrCode = VNBankQR.shared.parse(qrString: qrString) {
    if let vietQR = qrCode as? VietQR {
        print("Bank: \(vietQR.bankBin)")
        print("Account: \(vietQR.accountNumber)")
        print("Amount: \(vietQR.amount ?? "N/A")")
    }
}

// From image
if let qrCode = VNBankQR.shared.parse(image: qrImage) {
    print(qrCode.displayInfo)
}
```

### 3. Generate QR Code

```swift
let vietQR = VietQR(
    bankBin: "970436",
    accountNumber: "0011001800879",
    accountName: "NGUYEN VAN A",
    amount: "100000",
    purpose: "Payment for services"
)

// Generate QR image
if let image = VNBankQR.shared.generateVietQRImage(from: vietQR) {
    imageView.image = image
}

// Or generate string
let qrString = VNBankQR.shared.generateVietQRString(from: vietQR)
```

### 4. Scan QR Code

#### Basic Scanner

```swift
class MyViewController: UIViewController, BankQRScannerDelegate {
    func showScanner() {
        // Use default scanner
        let scanner = VNBankQR.shared.createScanner(delegate: self)
        present(scanner, animated: true)
    }

    func didScanBankQR(_ qrCode: any BankQRProtocol) {
        dismiss(animated: true)
        if let vietQR = qrCode as? VietQR {
            print("Scanned VietQR: \(vietQR.displayInfo)")
        }
    }

    func didFailScanning(error: BankQRError) {
        print("Scan failed: \(error.localizedDescription)")
    }
}
```

#### Scanner with Custom Overlay (UIView - Simple)

```swift
// Customize overlay appearance
let config = ScannerConfiguration(
    scanAreaSize: 280,              // Square size for scanning area
    scanAreaCornerRadius: 16,       // Corner radius
    overlayColor: UIColor.black.withAlphaComponent(0.6),  // Dimmed background
    scanAreaBorderColor: .systemGreen,  // Border color
    scanAreaBorderWidth: 3          // Border width
)
let scanner = VNBankQR.shared.createScanner(delegate: self, configuration: config)
present(scanner, animated: true)
```

#### Scanner with Custom UIView Overlay

```swift
// Create your own overlay view (for simple static UI)
let customOverlay = UIView()
// Add your custom UI elements (labels, frames, instructions, etc.)

let config = ScannerConfiguration(customOverlay: customOverlay)
let scanner = VNBankQR.shared.createScanner(delegate: self, configuration: config)
present(scanner, animated: true)
```

#### Scanner with Custom UIViewController Overlay (Recommended for Complex UI)

```swift
// Create a custom UIViewController for complex overlay UI
// Conform to BankQRScannerOverlay protocol to provide scan area
class ScannerOverlayViewController: UIViewController, BankQRScannerOverlay {
    private let scanFrameView = UIView()

    // Provide scan area to the scanner for focused QR detection
    var scanAreaRect: CGRect? {
        return scanFrameView.frame  // Return the frame of your scan area
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Add instruction labels
        // Add flashlight toggle button
        // Add manual entry button
        // Setup scanFrameView with your desired size and position
        // Handle user interactions
        // Full view controller lifecycle support
    }
}

// Use the custom overlay
let overlayVC = ScannerOverlayViewController()
let config = ScannerConfiguration(customOverlayViewController: overlayVC)
let scanner = VNBankQR.shared.createScanner(delegate: self, configuration: config)
present(scanner, animated: true)
```

#### BankQRScannerOverlay Protocol

Custom overlays (UIView or UIViewController) can conform to this protocol to provide the scan area:

```swift
public protocol BankQRScannerOverlay {
    /// The frame of the scanning area in the overlay's coordinate system
    /// This will be converted to AVFoundation's rectOfInterest
    /// Return nil to use the full screen as scanning area
    var scanAreaRect: CGRect? { get }
}
```

**How it works:**
1. Scanner checks if your custom overlay conforms to `BankQRScannerOverlay`
2. If yes, it calls `scanAreaRect` to get the scan area
3. Converts the rect to AVFoundation's `rectOfInterest` for focused scanning
4. If no protocol conformance, uses the configuration's `scanAreaSize`

**Key Features:**
- **Region of Interest**: Scanner automatically focuses on the square area for faster and more accurate scanning
- **Default Overlay**: Built-in overlay with dimmed background and clear scanning area
- **UIView Overlay**: Lightweight option for simple static UI elements
- **UIViewController Overlay**: Recommended for complex UI with buttons, forms, animations, and lifecycle management
- **Configurable**: Adjust size, colors, and appearance to match your app's design

**When to use each approach:**
- **Default**: Quick integration, no customization needed
- **UIView**: Simple overlays with static elements (labels, frames, branding)
- **UIViewController**: Complex overlays with buttons, flashlight control, manual entry, animations, or navigation

## Repository Structure

```
VNBankQR/
├── Package.swift                   # SPM manifest
├── README.md                       # This file
│
├── Sources/VNBankQR/              # Package source code
│   ├── VNBankQR.swift             # Main API
│   │
│   ├── Scanner/                    # Part 1: Scanner
│   │   ├── BankQRScannerViewController.swift
│   │   └── BankQRScannerDelegate.swift
│   │
│   ├── Parser/                     # Part 2: Parsers
│   │   └── VietQR/
│   │       └── VietQRParser.swift
│   │
│   ├── Generator/                  # Part 3: Generators
│   │   └── VietQR/
│   │       └── VietQRGenerator.swift
│   │
│   ├── Models/
│   │   └── VietQR/
│   │       ├── VietQRModel.swift
│   │       └── VietQRBankDirectory.swift
│   │
│   └── Core/
│       ├── BankQRProtocol.swift
│       ├── BankQRFactory.swift
│       └── BankQRError.swift
│
├── Tests/                          # Package tests
│   └── VNBankQRTests/
│
├── Demo/                           # Demo iOS App
│   ├── VNBankQRDemo.xcodeproj     # Xcode project
│   ├── VNBankQRDemo/              # Demo app source
│   │   ├── AppDelegate.swift
│   │   ├── SceneDelegate.swift
│   │   ├── ViewController.swift
│   │   └── Models/
│   └── VNBankQRDemoUITests/
│
└── Documentation/                  # Additional documentation
    ├── INSTALLATION_GUIDE.md
    ├── PACKAGE_SUMMARY.md
    ├── STRUCTURE.md
    └── VIETNAMESE_QR_ECOSYSTEM.md
```

## Supported Banks (VietQR)

- VietinBank (970415)
- Vietcombank (970436)
- BIDV (970418)
- Agribank (970405)
- Techcombank (970407)
- MB Bank (970422)
- ACB (970416)
- VPBank (970432)
- TPBank (970423)
- Sacombank (970403)
- BVBank (970454)
- And 40+ more banks...

## API Reference

### VNBankQR Main Class

```swift
// Scanner
func createScanner(
    delegate: BankQRScannerDelegate,
    configuration: ScannerConfiguration?
) -> BankQRScannerViewController

// Parser
func parse(qrString: String) -> (any BankQRProtocol)?
func parse(image: UIImage) -> (any BankQRProtocol)?
func parseVietQR(qrString: String) -> VietQR?
func parseVietQR(image: UIImage) -> VietQR?

// Generator
func generateImage(from qrCode: any BankQRProtocol, size: CGSize) -> UIImage?
func generateVietQRImage(from vietQR: VietQR, size: CGSize) -> UIImage?
func generateVietQRString(from vietQR: VietQR) -> String
```

### VietQR Model

```swift
public struct VietQR {
    public var bankBin: String
    public var accountNumber: String
    public var accountName: String?
    public var amount: String?
    public var purpose: String?
    public var serviceCode: String
    public var additionalData: AdditionalData?
}
```

## Distribution Methods

### Method 1: SPM (Recommended)
- Add package dependency in Xcode or Package.swift
- Automatic updates
- Dependency management

### Method 2: Copy Sources Folder
- Copy `Sources/VNBankQR/` to your project
- Add files to target
- Manual updates

### Method 3: CocoaPods (Future)
```ruby
pod 'VNBankQR', '~> 1.0'
```

## Requirements

- iOS 14.0+
- Swift 5.9+
- Xcode 15.0+

## License

[Your License Here]

## Author

[Your Team Name]

## Demo App

A complete demo iOS app is included in the `Demo/` folder. To run it:

1. Open `Demo/VNBankQRDemo.xcodeproj`
2. Build and run
3. The demo shows all features:
   - Generate VietQR codes
   - Scan QR codes with camera
   - Parse QR codes from images
   - Bank directory lookup

## References

- [NAPAS VietQR Specification](https://en.napas.com.vn/)
- [EMVCo QR Code Specification](https://www.emvco.com/)
- [Vietnamese QR Payment Ecosystem](./Documentation/VIETNAMESE_QR_ECOSYSTEM.md)
- [Installation Guide](./Documentation/INSTALLATION_GUIDE.md)
- [Package Structure](./Documentation/STRUCTURE.md)

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Support

For issues and questions, please open an issue on GitHub or contact [your-email@example.com]
