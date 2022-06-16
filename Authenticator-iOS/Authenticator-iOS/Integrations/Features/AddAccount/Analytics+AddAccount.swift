//
//  Analytics+AddAccount.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 05. 15..
//

import Combine
import Resolver
import AddAccountBusiness

extension AnyPublisher where Output == AddAccountEvent {
    func trackAddAccountEvents(analytics: AuthenticatorAnalytics = Resolver.resolve()) -> AnyPublisher<Output, Failure> {
        self.handleEvents(receiveOutput: { event in
            switch event {
            case .doneDidPress:
                analytics.track(name: "Add Account Done Pressed")
            case .failedToStartCamera:
                analytics.track(name: "Failed to start camera")
            case .qrCodeReadDidFail(error: let error):
                var properties: [String: String] = [:]
                if let useCaseError = error as? AddAccountUseCaseErrors {
                    switch useCaseError {
                    case .invalidURL:
                        properties["Reason"] = "InvalidURL"
                    case .notSupportedOTPMethod(let method):
                        properties["Reason"] = "Invalid method: \(method)"
                    case .notSupportedAlgorithm(let algorithm):
                        properties["Reason"] = "Invalid algorithm: \(algorithm)"
                    case .notSupportedDigitCount(let digit):
                        properties["Reason"] = "Invalid digits: \(digit)"
                    case .notSupportedPeriod(let period):
                        properties["Reason"] = "Invalid period: \(period)"
                    }
                } else {
                    properties["Reason"] = "Unknown"
                }
                analytics.track(name: "Failed to parse QR code", properties: properties)
            case .didCreateAccount(account: let account):
                analytics.track(name: "DidCreateNewAccount", properties: ["Issuer": account.issuer])
            }
        })
        .eraseToAnyPublisher()
    }
}
