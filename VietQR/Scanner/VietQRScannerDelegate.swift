//
//  VietQRScannerDelegate.swift
//  VietQR
//
//  Created by admin on 30/9/25.
//

public protocol VietQRScannerDelegate: AnyObject {
    func didScanVietQR(_ vietQR: VietQR)
    func didFailWithError(_ error: VietQRError)
}
