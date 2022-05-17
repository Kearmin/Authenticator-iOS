//
//  OverlayEvent.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 05. 18..
//

import Combine

typealias OverlayEventPublisher = AnyPublisher<OverlayEvent, Never>

enum OverlayEvent {
    case lock
    case unlock
}
