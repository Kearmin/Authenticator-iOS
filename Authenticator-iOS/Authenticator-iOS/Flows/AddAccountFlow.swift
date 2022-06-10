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
    private weak var addAccountViewController: AddAccountViewController?

    init(source: UIViewController?) {
        self.source = source
    }

    func start(dependencies: AddAccountComposer.Dependencies) {
        guard let source = source else { return }
        let (addAccountViewController, addAccountEventPublisher) = AddAccountComposer.addAccount(with: dependencies)
        setupEvents(publisher: addAccountEventPublisher)
        self.addAccountViewController = addAccountViewController
        let navController = addAccountViewController.embeddedInNavigationController
        navController.modalPresentationStyle = .fullScreen
        source.present(navController, animated: true)
    }

    func setupEvents(publisher: AnyPublisher<AddAccountEvent, Never>) {
        addAccountEventCancellable = publisher
            .receive(on: DispatchQueue.main)
            .sink { event in
                switch event {
                case .doneDidPress:
                    self.addAccountViewController?.dismiss(animated: true)
                case .failedToStartCamera:
                    let alert = UIAlertController(title: "Error", message: "Failed to open camera", preferredStyle: .alert)
                    alert.addAction(.init(title: "Ok", style: .default, handler: { _ in
                        self.addAccountViewController?.dismiss(animated: true)
                    }))
                    self.addAccountViewController?.present(alert, animated: true)
                case .qrCodeReadDidFail(let error):
                    let alert = UIAlertController(title: "Error", message: "\(error)", preferredStyle: .alert)
                    alert.addAction(.init(title: "Ok", style: .default, handler: { _ in
                        self.addAccountViewController?.addAccountView.resumeSession()
                    }))
                    self.addAccountViewController?.present(alert, animated: true)
                case .didCreateAccount:
                    self.addAccountViewController?.dismiss(animated: true)
                }
            }
    }
}
