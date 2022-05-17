//
//  OverlayAuthenticatorUseCaseOutputAdapter.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 05. 18..
//

import Combine
import OverlayBusiness

class OverlayAuthenticatorUseCaseOutputAdapter: OverlayAuthenticatorUseCaseOutput {
    let eventSubject: PassthroughSubject<OverlayEvent, Never>

    init(eventSubject: PassthroughSubject<OverlayEvent, Never>) {
        self.eventSubject = eventSubject
    }

    func shouldLock() {
        eventSubject.send(.lock)
    }

    func shouldUnlock() {
        eventSubject.send(.unlock)
    }
}
