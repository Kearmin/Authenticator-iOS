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
    }

    static func addAccount(with dependencies: Dependencies, output: PassthroughSubject<AddAccountEvent, Never>) -> AddAccountViewController {
        let useCaseAdapter = AddAccountSaveServiceAdapter(
            createAccountPublisher: dependencies.saveAccountPublisher,
            eventSubject: output)
        let useCase = AddAccountUseCase(saveService: useCaseAdapter)
        let viewController = AddAccountViewController(
            doneDidPress: { _ in
                output.send(.doneDidPress)
            },
            didFindQRCode: { [useCase] _, qrCode in
                do {
                    try useCase.createAccount(urlString: qrCode)
                } catch {
                    output.send(.qrCodeReadDidFail(error: error))
                }
            },
            failedToStart: { _ in
                output.send(.failedToStartCamera)
            })
        viewController.addAccountView.delegate = WeakRefProxy(viewController)
        return viewController
    }
}
