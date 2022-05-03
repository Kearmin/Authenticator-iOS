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
            analitycs.logEvent(name: "FailedToSaveAccount")
            throw error
        }
    }
}
