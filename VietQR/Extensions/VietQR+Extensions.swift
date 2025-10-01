////
////  File.swift
////  VietQR
////
////  Created by admin on 30/9/25.
////
//
//extension VietQR {
//    /// Convert VietQR to string format for QR generation
//    public func toQRString() -> String {
//        var components: [String] = []
//        components.append("bankBin=\(bankBin)")
//        components.append("accountNumber=\(accountNumber)")
//        components.append("template=\(template)")
//
//        if let amount = amount, !amount.isEmpty {
//            components.append("amount=\(amount)")
//        }
//        if let description = description, !description.isEmpty {
//            components.append("description=\(description)")
//        }
//        if let accountName = accountName, !accountName.isEmpty {
//            components.append("accountName=\(accountName)")
//        }
//
//        return components.joined(separator: "&")
//    }
//
//    /// Parse VietQR from QR code string
//    public static func fromQRString(_ qrString: String) -> VietQR? {
//        let components = qrString.components(separatedBy: "&")
//        var params: [String: String] = [:]
//
//        for component in components {
//            let keyValue = component.components(separatedBy: "=")
//            if keyValue.count == 2 {
//                params[keyValue[0]] = keyValue[1]
//            }
//        }
//
//        guard let bankBin = params["bankBin"],
//              let accountNumber = params["accountNumber"] else {
//            return nil
//        }
//
//        return VietQR(
//            bankBin: bankBin,
//            accountNumber: accountNumber,
//            template: params["template"] ?? "compact2",
//            amount: params["amount"],
//            description: params["description"],
//            accountName: params["accountName"]
//        )
//    }
//}
