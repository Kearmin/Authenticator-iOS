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

typealias TOTPPublisher = (_ secret: String,
                           _ date: Date,
                           _  digits: Int,
                           _ timeInterval: Int,
                           _ algorithm: AuthenticatorTOTPAlgorithm
) -> AnyPublisher<String?, Never>

protocol TOTPProvider {
    func totp(secret: String, date: Date, digits: Int, timeInterval: Int, algorithm: AuthenticatorTOTPAlgorithm) -> String?
    func totpPublisher(secret: String, date: Date, digits: Int, timeInterval: Int, algorithm: AuthenticatorTOTPAlgorithm) -> AnyPublisher<String?, Never>
}

class AuthenticatorTOTPProvider: TOTPProvider {
    func totp(secret: String, date: Date, digits: Int, timeInterval: Int, algorithm: AuthenticatorTOTPAlgorithm) -> String? {
        guard let data = base32DecodeToData(secret) else { return nil }
        let totp = TOTP(secret: data, digits: digits, timeInterval: timeInterval, algorithm: algorithm.swiftOTPAlgorithm)
        return totp?.generate(time: date)
    }

    func totpPublisher(secret: String, date: Date, digits: Int, timeInterval: Int, algorithm: AuthenticatorTOTPAlgorithm) -> AnyPublisher<String?, Never> {
        let totp = totp(secret: secret, date: date, digits: digits, timeInterval: timeInterval, algorithm: algorithm)
        return Just(totp).eraseToAnyPublisher()
    }
}
