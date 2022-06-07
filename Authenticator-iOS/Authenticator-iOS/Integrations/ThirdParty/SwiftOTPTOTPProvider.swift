//
//  AuthenticatorTOTPProvider.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 05. 14..
//

import Foundation
import Combine
import SwiftOTP

enum AuthenticatorTOTPAlgorithm {
    case sha1

    var swiftOTPAlgorithm: OTPAlgorithm {
        switch self {
        default:
            return .sha1
        }
    }
}

protocol AuthenticatorTOTPProvider {
    func totp(secret: String, date: Date, digits: Int, timeInterval: Int, algorithm: AuthenticatorTOTPAlgorithm) -> String?
}

class SwiftOTPTOTPProvider: AuthenticatorTOTPProvider {
    func totp(secret: String, date: Date, digits: Int, timeInterval: Int, algorithm: AuthenticatorTOTPAlgorithm) -> String? {
        guard let data = base32DecodeToData(secret) else { return nil }
        let totp = TOTP(secret: data, digits: digits, timeInterval: timeInterval, algorithm: algorithm.swiftOTPAlgorithm)
        return totp?.generate(time: date)
    }
}
