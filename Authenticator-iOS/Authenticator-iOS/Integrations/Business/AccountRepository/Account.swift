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
    public let isFavourite: Bool

    public init(id: UUID, issuer: String, secret: String, username: String, isFavourite: Bool = false) {
        self.id = id
        self.issuer = issuer
        self.secret = secret
        self.username = username
        self.isFavourite = isFavourite
    }
}
