//
//  ListEvent.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 05. 18..
//

import Combine

typealias ListEventPublisher = AnyPublisher<ListEvent, Never>

enum ListEvent: Equatable {
    case viewDidLoad
    case addAccountDidPress
    case deleteAccountDidPress(DeleteAccountContext)
    case editDidPress(EditAccountContext)
}
