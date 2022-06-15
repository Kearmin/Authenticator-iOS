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
import OSLog

protocol AuthenticatorAnalytics {
    func track(name: String)
    func track(name: String, properties: [String: Any]?)
}

class LogAnalytics: AuthenticatorAnalytics {
    private let logger: Logger

    init(logger: Logger) {
        self.logger = logger
    }

    func track(name: String) {
        track(name: name, properties: nil)
    }

    func track(name: String, properties: [String: Any]?) {
        logger.debug("AnalyticsEvent: name: \(name), properties: \(properties ?? [:])")
    }
}
