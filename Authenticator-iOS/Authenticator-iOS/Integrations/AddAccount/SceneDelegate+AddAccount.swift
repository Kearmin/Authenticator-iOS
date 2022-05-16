//
//  SceneDelegate+AddAccount.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 05. 14..
//

import Combine
import AddAccountView
import AccountRepository
import Resolver
import UIKit

extension SceneDelegate {
    func makeAddAccountViewController() -> AddAccountViewController {
        let dependencies = addAccountDependencies
        let addAccountEventSubject = PassthroughSubject<AddAccountEvent, Never>()
        let viewController = AddAccountComposer.addAccount(with: dependencies, output: addAccountEventSubject)
        addAccountEventSubscription = addAccountEventSubject
            .trackAddAccountEvents()
            .receive(on: DispatchQueue.main)
            .sink { event in
                self.handleAddAccountEvent(event, addAccountViewController: viewController)
            }
        return viewController
    }

    func handleAddAccountEvent(_ event: AddAccountEvent, addAccountViewController: AddAccountViewController) {
        switch event {
        case .doneDidPress:
            addAccountViewController.dismiss(animated: true)
            addAccountEventSubscription = nil
        case .failedToStartCamera:
            let alert = UIAlertController(title: "Error", message: "Failed to open camera", preferredStyle: .alert)
            alert.addAction(.init(title: "Ok", style: .default, handler: { _ in
                addAccountViewController.dismiss(animated: true)
                self.addAccountEventSubscription = nil
            }))
            addAccountViewController.present(alert, animated: true)
        case .qrCodeReadDidFail(let error):
            let alert = UIAlertController(title: "Error", message: "\(error)", preferredStyle: .alert)
            alert.addAction(.init(title: "Ok", style: .default, handler: { _ in
                addAccountViewController.addAccountView.resumeSession()
            }))
            addAccountViewController.present(alert, animated: true)
        case .didCreateAccount:
            Resolver.resolve(AppEventSubject.self).send(.newAccountCreated)
            addAccountViewController.dismiss(animated: true)
            addAccountEventSubscription = nil
        }
    }

    var addAccountDependencies: AddAccountComposer.Dependencies {
        .init(
            saveAccountPublisher: Resolver.resolve(AccountRepository.self).savePublisher(account:))
    }
}
