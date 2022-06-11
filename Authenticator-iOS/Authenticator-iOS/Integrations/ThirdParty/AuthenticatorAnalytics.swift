//
//  AuthenticatorAnalytics.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 05. 15..
//

import Foundation
import Combine
import Resolver
import AddAccountBusiness

protocol AuthenticatorAnalytics {
    func track(name: String)
    func track(name: String, properties: [String: Any]?)
}

class LogAnalytics: AuthenticatorAnalytics {
    func track(name: String) {
        track(name: name, properties: nil)
    }

    func track(name: String, properties: [String: Any]?) {
        print("AnalyticsEvent: name: \(name), properties: \(properties ?? [:])")
    }
}
