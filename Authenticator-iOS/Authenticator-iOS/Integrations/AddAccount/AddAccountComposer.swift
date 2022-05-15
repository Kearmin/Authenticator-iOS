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

enum AddAccountComposer {
    struct Dependencies {
        let saveAccountPublisher: (Account) -> AnyPublisher<Void, Error>
        let addAccountEventSubject: PassthroughSubject<AddAccountEvent, Never>
    }

    static func addAccount(with dependencies: Dependencies) -> AddAccountViewController {
        let useCaseAdapter = AddAccountSaveServiceAdapter(
            createAccountPublisher: dependencies.saveAccountPublisher,
            eventSubject: dependencies.addAccountEventSubject)
        let useCase = AddAccountUseCase(saveService: useCaseAdapter)
        let viewController = AddAccountViewController(
            doneDidPress: { _ in
                dependencies.addAccountEventSubject.send(.doneDidPress)
            },
            didFindQRCode: { [useCase] _, qrCode in
                do {
                    try useCase.createAccount(urlString: qrCode)
                } catch {
                    dependencies.addAccountEventSubject.send(.qrCodeReadDidFail(error: error))
                }
            },
            failedToStart: { _ in
                dependencies.addAccountEventSubject.send(.failedToStartCamera)
            })
        viewController.addAccountView.delegate = WeakProxy(viewController)
        return viewController
    }
}
