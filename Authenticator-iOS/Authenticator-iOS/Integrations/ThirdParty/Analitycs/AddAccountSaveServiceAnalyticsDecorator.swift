//
//  FireBaseAnalyticsAdapter+AddAccountService.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 05. 03..
//

import Resolver
import AddAccountBusiness

class AddAccountSaveServiceAnalyticsDecorator: AddAccountSaveService {
    let decorated: AddAccountSaveService
    let analitycs: AuthenticatorAnalytics

    init(_ decorated: AddAccountSaveService, analitycs: AuthenticatorAnalytics) {
        self.decorated = decorated
        self.analitycs = analitycs
    }

    func save(account: CreatAccountModel) throws {
        do {
            try decorated.save(account: account)
            let parameters: [String: Any] = [
                "issuer": account.issuer,
                "algorithm": account.algorithm,
                "digits": account.digits,
                "period": account.period
            ]
            analitycs.logEvent(name: "AuthenticatorAccountCreated", parameters: parameters)
        } catch {
            guard let useCaseError = error as? AddAccountUseCaseErrors else { throw error }
            switch useCaseError {
            case .invalidURL(let url):
                analitycs.logEvent(name: "FailedToSaveAccount_InvalidURL", parameters: ["URL": url])
            case .notSupportedOTPMethod(let method):
                analitycs.logEvent(name: "FailedToSaveAccount_NotSupportedOTP", parameters: ["method": method])
            case .notSupportedAlgorithm(let algorithm):
                analitycs.logEvent(name: "FailedToSaveAccount_NotSupportedAlgorithm", parameters: ["algorithm": algorithm])
            case .notSupportedDigitCount(let digit):
                analitycs.logEvent(name: "FailedToSaveAccount_NotSupportedDigit", parameters: ["digit": digit])
            case .notSupportedPeriod(let period):
                analitycs.logEvent(name: "FailedToSaveAccount_NotSupportedPeriod", parameters: ["period": period])
            }
            throw error
        }
    }
}
