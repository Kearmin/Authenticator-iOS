//
//  AddAccountComposer.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 05. 14..
//

import Foundation
import AddAccountView
import AddAccountBusiness
import Combine
import AccountRepository
import AuthenticatorListBusiness

enum AddAccountComposer {
    struct Dependencies {
        let saveAccountPublisher: (AuthenticatorAccountModel) -> AnyPublisher<Void, Error>
    }

    static func addAccount(with dependencies: Dependencies) -> (AddAccountViewController, AddAccountEventPublisher) {
        let eventSubject = PassthroughSubject<AddAccountEvent, Never>()
        let useCaseAdapter = AddAccountSaveServiceAdapter(
            createAccountPublisher: dependencies.saveAccountPublisher,
            eventSubject: eventSubject)
        let useCase = AddAccountUseCase(saveService: useCaseAdapter)
        let viewController = AddAccountViewController(
            doneDidPress: { _ in
                eventSubject.send(.doneDidPress)
            },
            didFindQRCode: { [useCase] _, qrCode in
                do {
                    try useCase.createAccount(urlString: qrCode)
                } catch {
                    eventSubject.send(.qrCodeReadDidFail(error: error))
                }
            },
            failedToStart: { _ in
                eventSubject.send(.failedToStartCamera)
            })
        viewController.addAccountView.delegate = WeakRefProxy(viewController)
        return (viewController, eventSubject.eraseToAnyPublisher())
    }
}
