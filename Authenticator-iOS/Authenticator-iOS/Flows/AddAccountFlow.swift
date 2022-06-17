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
    private var addAccountEventCancellable: AnyCancellable?
    private let addAccountFactory: AddAccountFactory
    private let showErrorFlow: ShowErrorFlow

    init(addAccountFactory: @escaping AddAccountFactory, showErrorFlow: ShowErrorFlow) {
        self.addAccountFactory = addAccountFactory
        self.showErrorFlow = showErrorFlow
    }

    func start(with source: UIViewController?) {
        guard let source = source else { return }
        let (addAccountViewController, addAccountEventPublisher) = addAccountFactory()
        // Tie flow to ViewController lifecycle
        addAccountViewController.reference = self
        setupEvents(addAccountViewController: addAccountViewController, publisher: addAccountEventPublisher)
        let navController = addAccountViewController.embeddedInNavigationController
        navController.modalPresentationStyle = .fullScreen
        onMain {
            source.present(navController, animated: true)
        }
    }
}

private extension AddAccountFlow {
    func setupEvents(addAccountViewController: AddAccountViewController, publisher: AnyPublisher<AddAccountEvent, Never>) {
        addAccountEventCancellable = publisher
            .sink { [weak addAccountViewController, showErrorFlow] event in
                switch event {
                case .doneDidPress:
                    onMain {
                        addAccountViewController?.dismiss(animated: true)
                    }
                case .failedToStartCamera:
                    let context = ErrorContext(
                        title: "Error".localized,
                        message: "Failed to open camera".localized) { [weak addAccountViewController] in
                            addAccountViewController?.dismiss(animated: true)
                        }
                    self.showErrorFlow.start(context: context, source: addAccountViewController)
                case .qrCodeReadDidFail(let error):
                    let context = ErrorContext(
                        title: "Error".localized,
                        message: "\(error.localizedDescription)") { [weak addAccountViewController] in
                            addAccountViewController?.addAccountView.resumeSession()
                        }
                    showErrorFlow.start(context: context, source: addAccountViewController)
                case .didCreateAccount:
                    onMain {
                        addAccountViewController?.dismiss(animated: true)
                    }
                }
            }
    }
}
