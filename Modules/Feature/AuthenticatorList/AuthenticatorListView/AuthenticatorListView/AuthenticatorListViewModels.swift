//
//  AuthenticatorListViewModels.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 04. 22..
//

import Foundation

public struct AuthenticatorListRow: Identifiable, Equatable {
    public var id: UUID
    public let issuer: String
    public let username: String
    public let TOTPCode: String
    public let onTrailingSwipeAction: () -> Void

    public static func == (lhs: AuthenticatorListRow, rhs: AuthenticatorListRow) -> Bool {
        lhs.id == rhs.id
        && lhs.issuer == rhs.issuer
        && lhs.username == rhs.username
        && lhs.TOTPCode == rhs.TOTPCode
    }

    public init(id: UUID, issuer: String, username: String, TOTPCode: String, onTrailingSwipeAction: @escaping () -> Void) {
        self.id = id
        self.issuer = issuer
        self.username = username
        self.TOTPCode = TOTPCode
        self.onTrailingSwipeAction = onTrailingSwipeAction
    }
}

public final class AuthenticatorListViewModel: ObservableObject {
    @Published public var countDownSeconds: String = ""
    @Published public var rows: [AuthenticatorListRow] = []

    public init() { }

    public init(countDownSeconds: String, rows: [AuthenticatorListRow]) {
        self.countDownSeconds = countDownSeconds
        self.rows = rows
    }
}
