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
import Combine

class AuthenticatorListOutputAdapter: AuthenticatorListViewOutput, AuthenticatorListErrorOutput {
    weak var listViewController: AuthenticatorListViewController?
    var presenter: AuthenticatorListPresenter?
    var hideToastCancellable: AnyCancellable?
    var hideToastSubject = PassthroughSubject<Void, Never>()

    internal init(listViewController: AuthenticatorListViewController? = nil, presenter: AuthenticatorListPresenter? = nil) {
        self.listViewController = listViewController
        self.presenter = presenter

        hideToastCancellable = hideToastSubject
            .debounce(for: .seconds(2), scheduler: RunLoop.main)
            .sink(receiveValue: { [weak self] _ in
                withAnimation(.easeInOut(duration: 0.2)) {
                    self?.listViewController?.viewModel.toast = nil
                }
            })
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
                    onDeletePress: { [presenter, listViewController] in
                        let alert = UIAlertController(
                            title: "Confirm",
                            message: "Do you really want to delete this account?",
                            preferredStyle: .alert)
                        alert.addAction(.init(title: "Cancel", style: .cancel, handler: nil))
                        alert.addAction(.init(title: "Delete", style: .destructive, handler: { [presenter] _ in
                            presenter?.delete(id: item.id)
                        }))
                        onMain {
                            listViewController?.present(alert, animated: true)
                        }
                    }, onDidPress: { [weak self] in
                        UIPasteboard.general.string = item.TOTPCode
                        onMainWithAnimation(.easeInOut(duration: 0.2)) {
                            self?.listViewController?.viewModel.toast = "Copied to clipboard"
                        }
                        self?.hideToastSubject.send()
                    }, onEditPress: { [weak self] in
                        let alert = UIAlertController(title: "Edit account", message: "", preferredStyle: .alert)
                        alert.addTextField { textField in
                            textField.placeholder = "Issuer"
                            textField.text = item.issuer
                        }
                        alert.addTextField { textField in
                            textField.placeholder = "Username"
                            textField.text = item.username
                        }
                        alert.addAction(.init(title: "Cancel", style: .cancel, handler: nil))
                        alert.addAction(.init(title: "Finish", style: .default, handler: { [weak self] _ in
                            self?.presenter?.update(
                                id: item.id,
                                issuer: alert.textFields?[0].text,
                                username: alert.textFields?[1].text)
                        }))
                        self?.listViewController?.present(alert, animated: true)
                    })
            })
        }
        onMain {
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
