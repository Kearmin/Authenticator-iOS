//
//  AuthenticatorListViewModels.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 04. 22..
//

import Foundation
import SwiftUI

public struct AuthenticatorListRow: Identifiable, Equatable {
    public let id: UUID
    public let issuer: String
    public let username: String
    public let TOTPCode: String
    public let isFavourite: Bool

    public static func == (lhs: AuthenticatorListRow, rhs: AuthenticatorListRow) -> Bool {
        lhs.id == rhs.id
        && lhs.issuer == rhs.issuer
        && lhs.username == rhs.username
        && lhs.TOTPCode == rhs.TOTPCode
        && lhs.isFavourite == rhs.isFavourite
    }

    public init(id: UUID, issuer: String, username: String, TOTPCode: String, isFavourite: Bool) {
        self.id = id
        self.issuer = issuer
        self.username = username
        self.TOTPCode = TOTPCode
        self.isFavourite = isFavourite
    }
}

public struct AuthenticatorListViewSection: Identifiable, Equatable {
    public var id: String {
        title
    }
    public let title: String
    public let rows: [AuthenticatorListRow]

    public init(title: String, rows: [AuthenticatorListRow]) {
        self.title = title
        self.rows = rows
    }
}

public final class AuthenticatorListViewModel: ObservableObject {
    @Published public var countDownSeconds: String = ""
    @Published public var sections: [AuthenticatorListViewSection] = []

    public init() { }

    public init(countDownSeconds: String, sections: [AuthenticatorListViewSection]) {
        self.countDownSeconds = countDownSeconds
        self.sections = sections
    }
}
