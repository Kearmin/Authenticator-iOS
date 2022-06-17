//
//  ListEvent.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 05. 18..
//

import Combine
import AuthenticatorListBusiness

typealias ListEventPublisher = AnyPublisher<ListEvent, Never>

struct DeleteAccountContext: Equatable {
    let callback: () -> Void

    static func == (lhs: DeleteAccountContext, rhs: DeleteAccountContext) -> Bool {
        true
    }
}

struct EditAccountContext: Equatable {
    let item: AuthenticatorListRowContent
    let callback: (_ issuer: String?, _ username: String?) -> Void

    static func == (lhs: EditAccountContext, rhs: EditAccountContext) -> Bool {
        lhs.item == rhs.item
    }
}

struct ErrorContext: Equatable {
    let title: String
    let message: String
    let okAction: (() -> Void)?

    init(title: String, message: String, okAction: (() -> Void)? = nil) {
        self.title = title
        self.message = message
        self.okAction = okAction
    }

    static func == (lhs: ErrorContext, rhs: ErrorContext) -> Bool {
        lhs.title == rhs.title
        && lhs.message == rhs.message
    }
}

enum ListEvent: Equatable {
    case viewDidLoad
    case addAccountDidPress
    case deleteAccountDidPress(DeleteAccountContext)
    case editDidPress(EditAccountContext)
    case onError(ErrorContext)
}
