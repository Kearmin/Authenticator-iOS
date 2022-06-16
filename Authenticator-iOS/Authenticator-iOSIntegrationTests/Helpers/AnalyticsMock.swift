//
//  AnalyticsMock.swift
//  Authenticator-iOSIntegrationTests
//
//  Created by Kertész Jenő Ármin on 2022. 06. 11..
//

@testable import Authenticator_iOS

class AnalyticsMock: AuthenticatorAnalytics {
    struct AnalyticsCall: Equatable {
        let name: String
        let properties: [String: String]?
    }

    var calls: [AnalyticsCall] = []
    var callCount: Int {
        calls.count
    }

    func track(name: String) {
        track(name: name, properties: nil)
    }

    func track(name: String, properties: [String: String]?) {
        calls.append(.init(name: name, properties: properties))
    }
}
