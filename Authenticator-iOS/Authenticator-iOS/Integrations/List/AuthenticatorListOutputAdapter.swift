//
//  AuthenticatorListOutputAdapter.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 05. 14..
//

import UIKit
import AuthenticatorListView
import AuthenticatorListBusiness
import SwiftUI

class AuthenticatorListOutputAdapter: AuthenticatorListViewOutput, AuthenticatorListErrorOutput {
    weak var listViewController: AuthenticatorListViewController?
    var presenter: AuthenticatorListPresenter?

    internal init(listViewController: AuthenticatorListViewController? = nil, presenter: AuthenticatorListPresenter? = nil) {
        self.listViewController = listViewController
        self.presenter = presenter
    }

    public func receive(countDown: String) {
        onMain {
            self.listViewController?.viewModel.countDownSeconds = countDown
        }
    }

    public func receive(rows: [AuthenticatorListRowContent]) {
        let content = rows.map { item in
            AuthenticatorListRow(
                id: item.id,
                issuer: item.issuer,
                username: item.username,
                TOTPCode: item.TOTPCode) {
                    self.presenter?.deleteAccount(id: item.id)
                }
        }
        onMainWithAnimation {
            self.listViewController?.viewModel.rows = content
        }
    }

    public func receive(error: Error) {
        let alert = UIAlertController(
            title: "Error",
            message: "\(error)",
            preferredStyle: .alert)
        onMain {
            self.listViewController?.present(alert, animated: true, completion: nil)
        }
    }
}
