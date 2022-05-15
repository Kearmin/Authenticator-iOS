//
//  Account.swift
//  AccountRepository
//
//  Created by Kertész Jenő Ármin on 2022. 04. 24..
//

import Foundation

public struct Account: Codable, Equatable, Identifiable {
    public let id: UUID
    public let issuer: String
    public let secret: String
    public let username: String

    public init(id: UUID, issuer: String, secret: String, username: String) {
        self.id = id
        self.issuer = issuer
        self.secret = secret
        self.username = username
    }
}
