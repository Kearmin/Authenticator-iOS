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
import Segment

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

class SegmentAnalytics: AuthenticatorAnalytics {
    func initialize() {
        let configuration = AnalyticsConfiguration(writeKey: "Your Segment key here")
        configuration.trackApplicationLifecycleEvents = true
        Analytics.setup(with: configuration)
    }

    func track(name: String) {
        track(name: name, properties: nil)
    }

    func track(name: String, properties: [String: Any]?) {
        Analytics.shared().track(name, properties: properties)
    }
}
