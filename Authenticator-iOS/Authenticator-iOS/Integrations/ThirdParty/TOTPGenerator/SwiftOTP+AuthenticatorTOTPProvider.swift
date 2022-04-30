//
//  SwiftOTP+AuthenticatorTOTPProvider.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 04. 24..
//

import SwiftOTP

final class SwiftOTPProvider: AuthenticatorTOTPProvider {
    func getTOTP(secret: String, date: Date) -> String? {
        guard let secret = base32DecodeToData(secret) else { return nil }
        let totp = TOTP(secret: secret, digits: 6, timeInterval: 30, algorithm: .sha1)
        return totp?.generate(time: date)
    }
}
