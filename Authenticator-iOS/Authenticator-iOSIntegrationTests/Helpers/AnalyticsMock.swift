//
//  AnalyticsMock.swift
//  Authenticator-iOSIntegrationTests
//
//  Created by Kertész Jenő Ármin on 2022. 06. 11..
//

@testable import Authenticator_iOS

class AnalyticsMock: AuthenticatorAnalytics {
    func track(name: String) {
    }

    func track(name: String, properties: [String: Any]?) {
    }
}
