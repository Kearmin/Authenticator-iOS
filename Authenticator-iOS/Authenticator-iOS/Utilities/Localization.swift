//
//  Localization.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 06. 11..
//

import Foundation

extension String {
    var localized: String {
        NSLocalizedString(
            self,
            tableName: nil,
            bundle: .current,
            value: self,
            comment: "")
    }
}
