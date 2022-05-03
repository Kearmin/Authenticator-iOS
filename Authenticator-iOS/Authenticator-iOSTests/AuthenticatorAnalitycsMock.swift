//
//  AuthenticatorAnalitycsMock.swift
//  Authenticator-iOSTests
//
//  Created by Kertész Jenő Ármin on 2022. 05. 03..
//

@testable import Authenticator_iOS

struct SomeError: Error, Equatable { }

class AuthenticatorAnalitycsMock: AuthenticatorAnalytics {
    var loggedEvents: [(name: String, parameters: [String: Any]?)] = []

    func logEvent(name: String) {
        logEvent(name: name, parameters: nil)
    }

    func logEvent(name: String, parameters: [String: Any]?) {
        loggedEvents.append((name, parameters))
    }
}
