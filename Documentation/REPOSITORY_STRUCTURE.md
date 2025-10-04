# VNBankQR - Repository Structure

## 📁 Complete Repository Layout

```
VNBankQR/                                    # Root repository
│
├── 📄 Package.swift                         # SPM manifest
├── 📄 README.md                             # Main documentation
├── 📄 .gitignore                            # Git ignore rules
│
├── 📂 Sources/                              # Package source code
│   └── 📂 VNBankQR/                         # Main package (13 files)
│       ├── 🎯 VNBankQR.swift                # Main API entry point
│       │
│       ├── 📂 Scanner/                      # PART 1: Scanner
│       │   ├── BankQRScannerViewController.swift
│       │   └── BankQRScannerDelegate.swift
│       │
│       ├── 📂 Parser/                       # PART 2: Parsers
│       │   └── 📂 VietQR/
│       │       └── VietQRParser.swift
│       │
│       ├── 📂 Generator/                    # PART 3: Generators
│       │   └── 📂 VietQR/
│       │       └── VietQRGenerator.swift
│       │
│       ├── 📂 Models/
│       │   └── 📂 VietQR/
│       │       ├── VietQRModel.swift
│       │       └── VietQRBankDirectory.swift
│       │
│       └── 📂 Core/
│           ├── BankQRProtocol.swift
│           ├── BankQRFactory.swift
│           ├── BankQRError.swift
│           ├── QRCodeImageGenerator.swift
│           └── QRCodeDetector.swift
│
├── 📂 Tests/                                # Package tests
│   └── 📂 VNBankQRTests/
│       └── VNBankQRTests.swift
│
├── 📂 Demo/                                 # Demo iOS App
│   ├── 📂 VNBankQRDemo.xcodeproj           # Xcode project
│   ├── 📂 VNBankQRDemo/                    # Demo app source
│   │   ├── AppDelegate.swift
│   │   ├── SceneDelegate.swift
│   │   ├── ViewController.swift            # Full demo implementation
│   │   ├── Models/
│   │   │   └── VietQR.swift               # Backward compatibility
│   │   ├── Assets.xcassets/
│   │   ├── Base.lproj/
│   │   └── Info.plist
│   │
│   └── 📂 VNBankQRDemoUITests/
│       ├── VNBankQRDemoUITests.swift
│       └── VNBankQRDemoUITestsLaunchTests.swift
│
└── 📂 Documentation/                        # Additional documentation
    ├── INSTALLATION_GUIDE.md                # Team installation guide
    ├── PACKAGE_SUMMARY.md                   # Package overview
    ├── STRUCTURE.md                         # Package architecture
    ├── VIETNAMESE_QR_ECOSYSTEM.md          # Vietnamese QR landscape
    ├── FINAL_STRUCTURE.md                   # Clean structure history
    └── REPOSITORY_STRUCTURE.md              # This file
```

## 📊 File Count Summary

| Category | Count | Location | Purpose |
|----------|-------|----------|---------|
| **Package Source** | 13 | `Sources/VNBankQR/` | Main SPM package |
| **Package Tests** | 1 | `Tests/VNBankQRTests/` | Unit tests |
| **Demo App** | 4 | `Demo/VNBankQRDemo/` | Example iOS app |
| **Demo UI Tests** | 2 | `Demo/VNBankQRDemoUITests/` | UI tests |
| **Documentation** | 6 | `Documentation/` | Guides & docs |
| **Config** | 2 | Root | Package.swift, README.md |

## 🎯 What Each Folder Does

### `/Sources/VNBankQR/` - Package Source
The main Swift package that can be distributed via SPM or copied to projects.

**Key Files:**
- `VNBankQR.swift` - Main public API
- `Scanner/` - Universal QR scanner for all Vietnamese banks
- `Parser/` - QR parsing logic (currently VietQR, ready for MoMo/ZaloPay/VNPay)
- `Generator/` - QR generation (strings & images)
- `Models/` - Data models (VietQR, bank directory)
- `Core/` - Base protocols, factory, utilities

### `/Tests/VNBankQRTests/` - Package Tests
Unit tests for the package. Run with `swift test` or Xcode Test.

### `/Demo/` - Demo iOS App
Complete example iOS app showing how to use VNBankQR package.

**Features demonstrated:**
- ✅ Generate VietQR codes with UI
- ✅ Scan QR codes using camera
- ✅ Parse QR codes from photo library
- ✅ Display bank information
- ✅ Error handling

**Files:**
- `VNBankQRDemo.xcodeproj` - Xcode project file
- `VNBankQRDemo/ViewController.swift` - Main demo implementation
- `VNBankQRDemo/Models/VietQR.swift` - Backward compatibility layer

### `/Documentation/` - Additional Docs
Extended documentation for the package.

- `INSTALLATION_GUIDE.md` - Step-by-step installation for team
- `PACKAGE_SUMMARY.md` - Package overview and features
- `STRUCTURE.md` - Original package architecture documentation
- `VIETNAMESE_QR_ECOSYSTEM.md` - Vietnamese QR payment landscape
- `FINAL_STRUCTURE.md` - Clean structure documentation
- `REPOSITORY_STRUCTURE.md` - This file

## 🔄 How to Use This Repository

### For Package Distribution (SPM)

**Option 1: Add as SPM dependency**
```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/yourteam/VNBankQR.git", from: "1.0.0")
]
```

**Option 2: Xcode SPM**
1. File > Add Packages
2. Enter repository URL
3. Select version

### For Manual Installation

**Copy package folder:**
```bash
cp -r Sources/VNBankQR /path/to/your/project/
```

Then add to your Xcode target.

### For Demo App

**Run the example:**
```bash
cd Demo
open VNBankQRDemo.xcodeproj
```

Build and run to see all features in action.

## 📦 Distribution Structure

### What to Distribute
When sharing this package with your team:

**Package Only (SPM or manual):**
- `Sources/VNBankQR/` ✅
- `Package.swift` ✅
- `README.md` ✅

**Package + Demo:**
- Everything above ✅
- `Demo/` ✅
- `Documentation/` ✅

### What NOT to Distribute
- `.git/` folder (version control history)
- `.claude/` folder (AI assistant data)
- `.DS_Store` files (macOS metadata)
- `DerivedData/` (Xcode build artifacts)

## 🚀 Development Workflow

### Adding New QR Type (e.g., MoMo)

1. **Create Parser**
   ```
   Sources/VNBankQR/Parser/MoMo/MoMoQRParser.swift
   ```

2. **Create Generator**
   ```
   Sources/VNBankQR/Generator/MoMo/MoMoQRGenerator.swift
   ```

3. **Create Model**
   ```
   Sources/VNBankQR/Models/MoMo/MoMoQRModel.swift
   ```

4. **Register in Factory**
   ```swift
   // BankQRFactory.swift
   private lazy var parsers: [any BankQRParser] = [
       VietQRParser.shared,
       MoMoQRParser.shared,  // ← Add here
   ]
   ```

5. **Update Demo**
   ```swift
   // Demo/VNBankQRDemo/ViewController.swift
   case let momoQR as MoMoQR:
       // Handle MoMo QR
   ```

## 🎯 Key Design Decisions

### Why This Structure?

1. **Standard SPM Layout**
   - `Sources/` for package code (standard)
   - `Tests/` for tests (standard)
   - `Package.swift` at root (required)

2. **Separate Demo App**
   - `Demo/` folder keeps example separate
   - Clear distinction between package and demo
   - Easy to exclude demo when distributing package

3. **Documentation Folder**
   - All guides in one place
   - Easy to find
   - Can be served as docs site

4. **Modular Package**
   - Clear separation: Scanner, Parser, Generator
   - Easy to add new QR types
   - Protocol-based extensibility

## 📈 Future Expansion

The structure is ready for:

- **MoMo QR** → `Parser/MoMo/`, `Generator/MoMo/`, `Models/MoMo/`
- **ZaloPay QR** → `Parser/ZaloPay/`, `Generator/ZaloPay/`, `Models/ZaloPay/`
- **VNPay QR** → `Parser/VNPay/`, `Generator/VNPay/`, `Models/VNPay/`
- **More Banks** → Add to `VietQRBankDirectory.swift`

## 📞 Support

- **Documentation**: See `Documentation/` folder
- **Examples**: See `Demo/VNBankQRDemo/`
- **Issues**: GitHub Issues
- **Team Guide**: `Documentation/INSTALLATION_GUIDE.md`

---

**Repository Reorganized**: October 2025
**Structure**: SPM Package + Demo App + Documentation
**Status**: ✅ Clean & Production Ready
