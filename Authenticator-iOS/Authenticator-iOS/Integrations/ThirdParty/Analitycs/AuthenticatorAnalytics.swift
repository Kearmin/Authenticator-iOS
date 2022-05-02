//
//  AuthenticatorAnalytics.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 05. 02..
//


protocol AuthenticatorAnalytics {
    func logEvent(name: String)
    func logEvent(name: String, parameters: [String: Any]?)
}
