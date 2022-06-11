//
//  AddAccountFlow.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 06. 06..
//

import Combine
import UIKit
import AddAccountView

class AddAccountFlow {
    private let source: UIViewController?
    private var addAccountEventCancellable: AnyCancellable?

    init(source: UIViewController?) {
        self.source = source
    }

    func start(with dependencies: AddAccountComposer.Dependencies) {
        guard let source = source else { return }
        let (addAccountViewController, addAccountEventPublisher) = AddAccountComposer.addAccount(with: dependencies)
        // Tie flow to ViewController lifecycle
        addAccountViewController.reference = self
        setupEvents(addAccountViewController: addAccountViewController, publisher: addAccountEventPublisher)
        let navController = addAccountViewController.embeddedInNavigationController
        navController.modalPresentationStyle = .fullScreen
        source.present(navController, animated: true)
    }
}

private extension AddAccountFlow {
    func setupEvents(addAccountViewController: AddAccountViewController, publisher: AnyPublisher<AddAccountEvent, Never>) {
        addAccountEventCancellable = publisher
            .receive(on: DispatchQueue.main)
            .sink { [weak addAccountViewController] event in
                switch event {
                case .doneDidPress:
                    addAccountViewController?.dismiss(animated: true)
                case .failedToStartCamera:
                    let alert = UIAlertController(title: "Error", message: "Failed to open camera", preferredStyle: .alert)
                    alert.addAction(.init(title: "Ok", style: .default, handler: { _ in
                        addAccountViewController?.dismiss(animated: true)
                    }))
                    addAccountViewController?.present(alert, animated: true)
                case .qrCodeReadDidFail(let error):
                    let alert = UIAlertController(title: "Error", message: "\(error)", preferredStyle: .alert)
                    alert.addAction(.init(title: "Ok", style: .default, handler: { _ in
                        addAccountViewController?.addAccountView.resumeSession()
                    }))
                    addAccountViewController?.present(alert, animated: true)
                case .didCreateAccount:
                    addAccountViewController?.dismiss(animated: true)
                }
            }
    }
}
