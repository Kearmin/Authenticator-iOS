//
//  AppConfig.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 05. 18..
//

import Foundation

enum AppConfig {
    enum Config {
        case debug
        case release
    }

    static var isRunningUnitTests: Bool {
        ProcessInfo.processInfo.environment["UNITTEST"] == "1"
    }

    static var isDebug: Bool {
        config == .debug
    }

    static var config: Config {
        #if DEBUG
        return .debug
        #else
        return .release
        #endif
    }
}
