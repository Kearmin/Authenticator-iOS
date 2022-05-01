//
//  AuthenticatorListViewController.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 04. 21..
//

import AuthenticatorListView
import AuthenticatorListBusiness
import SwiftUI
import Resolver
import UIKitNavigator

final class AuthenticatorListComposer2 {
    let viewController: AuthenticatorListViewController
    let viewModel: AuthenticatorListViewModel
    let presenter: AuthenticatorListPresenter
    var appEventObservable: AppEventObservable
    let navigator: UIKitNavigator

    init(viewController: AuthenticatorListViewController,
         viewModel: AuthenticatorListViewModel,
         presenter: AuthenticatorListPresenter,
         appEventObservable: AppEventObservable,
         navigator: UIKitNavigator)
    {
        self.viewModel = viewModel
        self.presenter = presenter
        self.appEventObservable = appEventObservable
        self.navigator = navigator
        self.viewController = viewController
        viewController.delegate = self
        presenter.output = self
        appEventObservable.observeWeakly(self)
    }

    func load() {
        Queues.generalBackgroundQueue.async {
            self.presenter.load()
        }
    }
}

extension AuthenticatorListComposer2: AuthenticatorListViewControllerDelegate {
    func onViewDidLoad(_ authenticatorListViewController: AuthenticatorListViewController) {
        load()
    }

    func didPressAddAccountButton(_ authenticatorListViewController: AuthenticatorListViewController) {
        let addAccountComposer = AddAccountComposer()
        addAccountComposer.delegate = AddAccountDelegateComposition2(listComposer: self, navigator: navigator)
        navigator.presentFullScreenEmbeddedInNavigationController(view: addAccountComposer, source: viewController)
    }
}

extension AuthenticatorListComposer2: AuthenticatorListPresenterDelegate {
    public func receive(countDown: String) {
        onMain {
            self.viewModel.countDownSeconds = countDown
        }
    }

    func receive(rows: [AuthenticatorListRowContent]) {
        onMain {
            self.viewModel.rows = rows.map { row in
                    .init(
                        id: row.id,
                        issuer: row.issuer,
                        username: row.username,
                        TOTPCode: row.TOTPCode,
                        onTrailingSwipeAction: { [weak self] in
                            self?.presenter.deleteAccount(id: row.id)
                        })
            }
        }
    }
}

extension AuthenticatorListComposer2: AppEventObserver {
    func handle(event: AppEvent) {
        switch event {
        case .appDidEnterForeground:
            load()
        default:
            break
        }
    }
}

protocol AuthenticatorListViewControllerDelegate: AnyObject {
    func onViewDidLoad(_ authenticatorListViewController: AuthenticatorListViewController)
    func didPressAddAccountButton(_ authenticatorListViewController: AuthenticatorListViewController)
}


final class AuthenticatorListViewController: UIHostingController<AuthenticatorListView> {

    var delegate: AuthenticatorListViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = .init(
            systemItem: .add,
            primaryAction: .init(handler: { [unowned self] _ in
                self.delegate?.didPressAddAccountButton(self)
            }),
            menu: nil)
    }
}
