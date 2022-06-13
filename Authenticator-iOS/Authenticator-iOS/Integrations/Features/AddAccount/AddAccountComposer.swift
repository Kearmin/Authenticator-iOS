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
import Repository
import AuthenticatorListBusiness

typealias AddAccountFactory = () -> (AddAccountViewController, AddAccountEventPublisher)

enum AddAccountComposer {
    struct Dependencies {
        let saveAccountPublisher: (AuthenticatorAccountModel) -> AnyPublisher<Void, Error>
        let analytics: AuthenticatorAnalytics
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
            })
        let viewDelegateAdapter = AddAccountViewDelegateAdapter(useCase: useCase, eventSubject: eventSubject)
        viewController.addAccountView.delegate = viewDelegateAdapter
        let trackedEvenPublisher = eventSubject.eraseToAnyPublisher().trackAddAccountEvents(analytics: dependencies.analytics)
        return (viewController, trackedEvenPublisher)
    }
}
