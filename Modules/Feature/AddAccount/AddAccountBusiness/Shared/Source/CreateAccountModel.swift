//
//  CreateAccountModel.swift
//  AddAccountBusiness
//
//  Created by Kertész Jenő Ármin on 2022. 04. 30..
//

import Foundation

public struct CreatAccountModel: Equatable {
    public let issuer: String
    public let secret: String
    public let username: String

    public init(issuer: String, secret: String, username: String) {
        self.issuer = issuer
        self.secret = secret
        self.username = username
    }
}
