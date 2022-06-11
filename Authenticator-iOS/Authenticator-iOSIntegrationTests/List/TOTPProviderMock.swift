//
//  TOTPProviderMock.swift
//  Authenticator-iOSIntegrationTests
//
//  Created by Kertész Jenő Ármin on 2022. 06. 11..
//

import AuthenticatorListBusiness
@testable import Authenticator_iOS
import Combine

class TOTPProviderMock: AuthenticatorTOTPProvider {
    struct Params: Equatable {
        let secret: String
        let date: Date
        let digits: Int
        let timeInterval: Int
        let algorithm: AuthenticatorTOTPAlgorithm

        static func == (lhs: Params, rhs: Params) -> Bool {
            return lhs.secret == rhs.secret
            && lhs.digits == rhs.digits
            && lhs.timeInterval == rhs.timeInterval
            && lhs.algorithm == rhs.algorithm
            && abs(lhs.date.timeIntervalSinceReferenceDate - lhs.date.timeIntervalSinceReferenceDate) < 1
        }
    }

    var result = ""
    var capturedParams: [Params] = []

    func totp(secret: String, date: Date, digits: Int, timeInterval: Int, algorithm: AuthenticatorTOTPAlgorithm) -> String? {
        capturedParams.append(Params(
            secret: secret,
            date: date,
            digits: digits,
            timeInterval: timeInterval,
            algorithm: algorithm))
        return result
    }

    func totpPublisher(secret: String, date: Date, digits: Int, timeInterval: Int, algorithm: AuthenticatorTOTPAlgorithm) -> AnyPublisher<String?, Never> {
        Empty().eraseToAnyPublisher()
    }
}
