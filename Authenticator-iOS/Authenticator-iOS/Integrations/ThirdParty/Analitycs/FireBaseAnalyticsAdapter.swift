//
//  FireBaseAnalytics+AuthenticatorAnalitycs.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 05. 02..
//

import FirebaseAnalytics

class FireBaseAnalitycsAdapter: AuthenticatorAnalytics {
    func logEvent(name: String) {
        logEvent(name: name, parameters: nil)
    }

    func logEvent(name: String, parameters: [String: Any]?) {
        Analytics.logEvent(name, parameters: parameters)
    }
}
