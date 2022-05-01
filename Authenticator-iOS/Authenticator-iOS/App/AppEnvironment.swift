//
//  AppEnvironment.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 05. 02..
//

import Foundation

enum Configuration {
    case debug
    case release
}

enum AppEnvironment {
    // Defined in xctestplan
    static let isRunningTests: Bool = UserDefaults.standard.bool(forKey: "isTest")

    static let configuration: Configuration = {
        #if DEBUG
        return .debug
        #else
        return .release
        #endif
    }()
}
