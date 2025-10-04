# Vietnamese QR Code Payment Ecosystem

## Overview

This document describes the Vietnamese QR code payment landscape and the library's support strategy.

## Current Implementation Status

### ✅ VietQR (Implemented)
- **Standard**: NAPAS VietQR - EMVCo QR Code format
- **Coverage**: 40+ Vietnamese banks
- **Format**: Tag-Length-Value (TLV) with CRC-16 checksum
- **Banks Supported**:
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
  - And more...

**Capabilities**:
- Parse QR codes from string or image
- Generate QR codes with bank account info
- Support for static and dynamic QR codes
- Transaction amount, purpose, additional data
- Bank directory lookup

## Future Vietnamese QR Code Types

### 🔜 MoMo QR (Planned)
- **Type**: E-wallet QR code
- **Users**: 31M+ users (largest e-wallet in Vietnam)
- **Standard**: VietQR base + proprietary extensions
- **Key Feature**: Field 80 contains last 3 digits of phone number
- **Compatibility**: Can be scanned by banking apps and MoMo
- **Infrastructure**: Uses BVBank for receiving funds

### 🔜 ZaloPay QR (Planned)
- **Type**: E-wallet QR code
- **Integration**: Part of Zalo messaging app ecosystem
- **Standard**: VietQR base + proprietary fields
- **Compatibility**: ZaloPay can scan VietQR, MoMo, ZaloPay
- **Note**: Other apps cannot scan ZaloPay QR (least compatible)
- **Infrastructure**: Uses BVBank for receiving funds

### 🔜 VNPay QR (Planned)
- **Type**: Payment gateway QR code
- **Standard**: Based on VietQR standard
- **Partnership**: Integrated with Visa
- **Compatibility**: Can be scanned by most banking apps
- **Use Case**: Merchant payments, online-to-offline

## QR Code Compatibility Matrix

| QR Type | Can Generate | Can Scan/Parse | Compatible Scanners |
|---------|-------------|----------------|---------------------|
| **VietQR** | ✅ Yes | ✅ Yes | ALL apps (universal) |
| **MoMo QR** | 🔜 Future | 🔜 Future | Banks, MoMo, ZaloPay |
| **ZaloPay QR** | 🔜 Future | 🔜 Future | ZaloPay only |
| **VNPay QR** | 🔜 Future | 🔜 Future | Banks, VNPay |

## Technical Architecture

The library is designed with a modular, protocol-oriented architecture:

```
VietQR/
├── Core/                              # Generic QR infrastructure
│   ├── QRCodeProtocol.swift          # Base protocols
│   ├── QRCodeFactory.swift           # Auto-detection
│   └── QRCodeImageGenerator.swift    # Image generation
│
├── QRCodeTypes/
│   ├── VietQR/                       # ✅ Implemented
│   ├── MoMoQR/                       # 🔜 Future
│   ├── ZaloPayQR/                    # 🔜 Future
│   └── VNPayQR/                      # 🔜 Future
│
└── Scanner/                          # Generic scanner
    └── QRScannerViewController.swift # Auto-detects all types
```

## Why This Approach?

### Benefits
1. **VietQR covers 95% of bank-to-bank use cases**
2. **Universal compatibility** - VietQR can be scanned by all apps
3. **Easy to extend** - Add MoMo/ZaloPay/VNPay when needed
4. **Clean separation** - Each QR type is isolated
5. **Auto-detection** - Scanner automatically identifies QR type

### When to Add E-Wallet Support
Consider adding MoMo, ZaloPay, VNPay QR support when:
- Users need to scan e-wallet merchant QR codes
- App needs to generate e-wallet-compatible QR codes
- Full payment ecosystem coverage is required
- E-wallet integration is part of product roadmap

## Implementation Priority

**Phase 1 (Current)**: ✅ VietQR
- Covers all major Vietnamese banks
- EMVCo standard compliance
- Universal compatibility

**Phase 2 (Future)**: MoMo QR
- Largest e-wallet (31M users)
- High merchant adoption
- VietQR base + extensions

**Phase 3 (Future)**: ZaloPay QR
- Zalo ecosystem integration
- Wide user base
- VietQR base + proprietary fields

**Phase 4 (Future)**: VNPay QR
- Payment gateway integration
- Visa partnership
- Merchant payment focus

## Usage Statistics (2024)

- **QR Code Growth**: 106.7% year-over-year
- **Transaction Volume**: 9.56 billion transactions (+30%)
- **Consumer Adoption**: 62% of Vietnamese use QR payments (up from 35% in 2021)
- **Network**: 40+ banks in VietQR network

## References

- NAPAS VietQR Specification v1.0 (September 2021)
- EMVCo QR Code Specification
- State Bank of Vietnam QR Code Standards
- MoMo, ZaloPay, VNPay technical documentation (when available)
