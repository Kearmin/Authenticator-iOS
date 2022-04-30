//
//  TOTPGenerator.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 04. 24..
//

import SwiftOTP

protocol AuthenticatorTOTPProvider {
    func getTOTP(secret: String, date: Date) -> String?
}
