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
                    onDeletePress: { [weak self] in
                        let deleteAccountFlow = DeleteAccountFlow(source: self?.listViewController) { [weak self] in
                            self?.presenter?.delete(id: item.id)
                        }
                        deleteAccountFlow.start()
                    }, onDidPress: { [weak self] in
                        UIPasteboard.general.string = item.TOTPCode
                        onMainWithAnimation(.easeInOut(duration: 0.2)) {
                            self?.listViewController?.viewModel.toast = "Copied to clipboard"
                        }
                        self?.hideToastSubject.send()
                    }, onEditPress: { [listViewController] in
                        let editFlow = EditAccountFlow(account: item, source: listViewController) { [weak self] issuer, username in
                            self?.presenter?.update(id: item.id, issuer: issuer, username: username)
                        }
                        editFlow.start()
                    })
            })
        }
        onMain {
            self.listViewController?.viewModel.sections = sections
        }
    }

    public func receive(error: Error) {
        let showErrorFlow = ShowErrorFlow(source: listViewController, title: "Error", message: "\(error)")
        showErrorFlow.start()
    }
}
