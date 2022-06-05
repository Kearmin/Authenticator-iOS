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

    public func receive(content: AuthenticatorListContent) {
        let sections = content.map { section in
            AuthenticatorListViewSection(title: section.title, rows: section.rowContent.map { item in
                AuthenticatorListRow(
                    id: item.id,
                    issuer: item.issuer,
                    username: item.username,
                    TOTPCode: item.TOTPCode,
                    isFavourite: item.isFavourite,
                    onFavouritePress: { [presenter] in
                        presenter?.favourite(id: item.id)
                    },
                    onDeletePress: { [presenter] in
                        presenter?.delete(id: item.id)
                    }, onDidPress: {
                        print("Pressed: \(item.username)")
                    })
            })
        }
        onMainWithAnimation {
            self.listViewController?.viewModel.sections = sections
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
