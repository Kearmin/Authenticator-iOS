//
//  AuthenticatorListContent.swift
//  AuthenticatorListBusiness
//
//  Created by Kertész Jenő Ármin on 2022. 06. 04..
//

import Foundation

public struct AuthenticatorListRowContent: Identifiable, Equatable {
    public var id: UUID
    public let issuer: String
    public let username: String
    public let TOTPCode: String
    public let isFavourite: Bool

    public init(id: UUID, issuer: String, username: String, TOTPCode: String, isFavourite: Bool) {
        self.id = id
        self.issuer = issuer
        self.username = username
        self.TOTPCode = TOTPCode
        self.isFavourite = isFavourite
    }
}

public struct AuthencticatorListSection: Equatable {
    public let title: String
    public let rowContent: [AuthenticatorListRowContent]

    public init(title: String, rowContent: [AuthenticatorListRowContent]) {
        self.title = title
        self.rowContent = rowContent
    }
}

public typealias AuthenticatorListContent = [AuthencticatorListSection]
