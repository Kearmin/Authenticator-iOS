//
//  AddAccountEvent.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 05. 15..
//

import Combine
import AccountRepository

typealias AddAccountEventPublisher = AnyPublisher<AddAccountEvent, Never>

enum AddAccountEvent {
    case doneDidPress
    case failedToStartCamera
    case qrCodeReadDidFail(error: Error)
    case didCreateAccount(account: Account)
}
