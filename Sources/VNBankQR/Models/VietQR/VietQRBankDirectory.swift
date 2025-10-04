//
//  VietQRBankDirectory.swift
//  VietQR
//
//  Vietnamese bank directory with BIN codes
//

import Foundation

// MARK: - Bank Info

public struct BankInfo {
    public let bin: String
    public let shortName: String
    public let fullName: String

    public init(bin: String, shortName: String, fullName: String) {
        self.bin = bin
        self.shortName = shortName
        self.fullName = fullName
    }
}

// MARK: - Bank Directory

public class VietQRBankDirectory {
    public static let shared = VietQRBankDirectory()
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

    public func getBankName(bin: String) -> String? {
        return banks[bin]?.shortName
    }

    public func getAllBanks() -> [BankInfo] {
        return Array(banks.values).sorted { $0.shortName < $1.shortName }
    }
}
