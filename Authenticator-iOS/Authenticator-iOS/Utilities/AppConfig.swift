//
//  AppConfig.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 05. 18..
//

import Foundation

enum AppConfig {
    static var isRunningUnitTests: Bool {
        UserDefaults.standard.bool(forKey: "isUnitTest")
    }
}
