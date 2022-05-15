//
//  AuthenticatorListViewController.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 05. 12..
//

import SwiftUI

public final class AuthenticatorListViewController: UIHostingController<AuthenticatorListView> {
    public let viewModel: AuthenticatorListViewModel
    public let didPressAddAccount: (AuthenticatorListViewController) -> Void
    public let onViewDidLoad: () -> Void

    public init(viewModel: AuthenticatorListViewModel,
                didPressAddAccount: @escaping (AuthenticatorListViewController) -> Void,
                onViewDidLoad: @escaping () -> Void) {
        self.viewModel = viewModel
        self.didPressAddAccount = didPressAddAccount
        self.onViewDidLoad = onViewDidLoad
        super.init(rootView: .init(viewModel: viewModel))
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(didPressAddAccountButton))
        onViewDidLoad()
    }

    @objc
    public func didPressAddAccountButton() {
        didPressAddAccount(self)
    }
}
