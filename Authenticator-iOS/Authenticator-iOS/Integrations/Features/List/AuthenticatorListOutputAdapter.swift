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
    var listEventPublisher: PassthroughSubject<ListEvent, Never>
    var presenter: AuthenticatorListPresenter?
    var hideToastCancellable: AnyCancellable?
    var hideToastSubject = PassthroughSubject<Void, Never>()

    internal init(
        listViewController: AuthenticatorListViewController? = nil,
        presenter: AuthenticatorListPresenter? = nil,
        listEventPublisher: PassthroughSubject<ListEvent, Never>
    ) {
        self.listViewController = listViewController
        self.presenter = presenter
        self.listEventPublisher = listEventPublisher

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
                    onDeletePress: { [listEventPublisher] in
                        let context = DeleteAccountContext { [weak self] in
                            self?.presenter?.delete(id: item.id)
                        }
                        listEventPublisher.send(.deleteAccountDidPress(context))
                    },
                    onDidPress: { [weak self] in
                        UIPasteboard.general.string = item.TOTPCode
                        onMainWithAnimation(.easeInOut(duration: 0.2)) {
                            self?.listViewController?.viewModel.toast = "Copied to clipboard".localized
                        }
                        self?.hideToastSubject.send()
                    },
                    onEditPress: { [listEventPublisher] in
                        let context = EditAccountContext(item: item) { [weak self] issuer, username in
                            self?.presenter?.update(id: item.id, issuer: issuer, username: username)
                        }
                        listEventPublisher.send(.editDidPress(context))
                    })
            })
        }
        onMain {
            self.listViewController?.viewModel.sections = sections
        }
    }

    public func receive(error: Error) {
        listEventPublisher.send(.onError(.init(title: "Error".localized, message: "\(error)")))
    }
}
