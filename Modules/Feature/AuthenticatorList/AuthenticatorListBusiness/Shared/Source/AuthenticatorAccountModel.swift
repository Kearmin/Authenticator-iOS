//
//  AuthenticatorAccountModel.swift
//  AuthenticatorListBusiness
//
//  Created by Kertész Jenő Ármin on 2022. 06. 03..
//

import Foundation

public struct AuthenticatorAccountModel: Codable, Identifiable, Equatable {
    public let id: UUID
    public let issuer: String
    public let username: String
    public let secret: String
    public var isFavourite: Bool
    public var createdAt: TimeInterval

    public init(id: UUID, issuer: String, username: String, secret: String, isFavourite: Bool = false, createdAt: TimeInterval = Date().timeIntervalSince1970) {
        self.id = id
        self.issuer = issuer
        self.username = username
        self.secret = secret
        self.isFavourite = isFavourite
        self.createdAt = createdAt
    }
}
