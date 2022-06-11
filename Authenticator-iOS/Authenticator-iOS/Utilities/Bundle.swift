//
//  Bundle.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 06. 11..
//

import Foundation

extension Bundle {
    static var current: Bundle {
        class __ { } // swiftlint:disable:this type_name
        return Bundle(for: __.self)
    }
}
