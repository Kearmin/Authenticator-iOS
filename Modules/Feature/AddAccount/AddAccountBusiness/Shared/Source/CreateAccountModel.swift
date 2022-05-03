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
    public let digits: String
    public let period: String
    public let algorithm: String

    public init(issuer: String, secret: String, username: String, digits: String, period: String, algorithm: String) {
        self.issuer = issuer
        self.secret = secret
        self.username = username
        self.digits = digits
        self.period = period
        self.algorithm = algorithm
    }
}
