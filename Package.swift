// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "VNBankQR",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "VNBankQR",
            targets: ["VNBankQR"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "VNBankQR",
            dependencies: [],
            path: "Sources/VNBankQR"
        ),
        .testTarget(
            name: "VNBankQRTests",
            dependencies: ["VNBankQR"],
            path: "Tests/VNBankQRTests"
        ),
    ],
    swiftLanguageVersions: [.v5],
    exclude: [
        "Demo",
        "Documentation",
        "VietQR"
    ]
)
