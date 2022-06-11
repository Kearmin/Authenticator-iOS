//
//  AddAccountViewDelegateAdapter.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 06. 11..
//

import AddAccountView
import AddAccountBusiness
import Combine

class AddAccountViewDelegateAdapter: AddAccountViewDelegate {
    let useCase: AddAccountUseCase
    let eventSubject: PassthroughSubject<AddAccountEvent, Never>

    init(useCase: AddAccountUseCase, eventSubject: PassthroughSubject<AddAccountEvent, Never>) {
        self.useCase = useCase
        self.eventSubject = eventSubject
    }

    func didFindQRCode(code: String) {
        do {
            try useCase.createAccount(urlString: code)
        } catch {
            eventSubject.send(.qrCodeReadDidFail(error: error))
        }
    }

    func failedToStart() {
        eventSubject.send(.failedToStartCamera)
    }
}
