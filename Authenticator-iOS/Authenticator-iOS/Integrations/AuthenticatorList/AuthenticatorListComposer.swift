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

protocol AuthenticatorListComposerDelegate: AnyObject {
    func didPressAddAccountButton(_ authenticatorListViewComposer: AuthenticatorListComposer)
}

public final class AuthenticatorListComposer: UIHostingController<AuthenticatorListView> {
    private let viewModel: AuthenticatorListViewModel
    private let presenter: AuthenticatorListPresenter
    weak var delegate: AuthenticatorListComposerDelegate?
    private var appEventObservable: AppEventObservable

    init(rootView: AuthenticatorListView,
         viewModel: AuthenticatorListViewModel,
         presenter: AuthenticatorListPresenter,
         appEventObservable: AppEventObservable)
    {
        self.viewModel = viewModel
        self.presenter = presenter
        self.appEventObservable = appEventObservable
        super.init(rootView: rootView)
    }

    deinit {
        appEventObservable.removeObserver(self)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(didPressAddAccountButton))
        presenter.output = self
        appEventObservable.observe(self)
        loadPresenter()
    }

    func reload() {
        loadPresenter()
    }

    private func loadPresenter() {
        Queues.generalBackgroundQueue.async {
            self.presenter.load()
        }
    }

    @objc
    private func didPressAddAccountButton() {
        self.delegate?.didPressAddAccountButton(self)
    }
}

extension AuthenticatorListComposer: AuthenticatorListPresenterDelegate {
    public func receive(countDown: String) {
        onMain {
            self.viewModel.countDownSeconds = countDown
        }
    }

    public func receive(rows: [AuthenticatorListRowContent]) {
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

extension AuthenticatorListComposer: AppEventObserver {
    func handle(event: AppEvent) {
        switch event {
        case .appDidEnterForeground:
            loadPresenter()
        default:
            break
        }
    }
}
