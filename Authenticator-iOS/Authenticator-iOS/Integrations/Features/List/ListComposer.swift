//
//  ListComposer.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 05. 14..
//

import Foundation
import AuthenticatorListView
import AuthenticatorListBusiness
import AccountRepository
import UIKit
import Combine
import Resolver


enum ListComposer {
    struct Dependencies {
        var totpProvider: TOTPProvider
        var readAccounts: () -> AnyPublisher<[Account], Never>
        var delete: (_ accountID: UUID) -> AnyPublisher<Void, Error>
        var appEventPublisher: AnyPublisher<AppEvent, Never>
    }

    static func list(dependencies: ListComposer.Dependencies) -> (AuthenticatorListViewController, ListEventPublisher) {
        let eventSubject = PassthroughSubject<ListEvent, Never>()
        let presenterService = AuthenticatorListPresenterServiceAdapter(
            totpProvider: dependencies.totpProvider,
            appEventPublisher: dependencies.appEventPublisher,
            readAccounts: dependencies.readAccounts,
            delete: dependencies.delete)
        let presenter = AuthenticatorListPresenter(service: presenterService, cycleLength: Constants.appCycleLength)
        presenterService.presenter = presenter
        let viewController = AuthenticatorListViewController(
            viewModel: .init(),
            didPressAddAccount: { _ in eventSubject.send(.addAccountDidPress) },
            onViewDidLoad: {
                eventSubject.send(.viewDidLoad)
                presenter.load()
            })
        let adapter = AuthenticatorListOutputAdapter(listViewController: viewController, presenter: presenter)
        presenter.output = adapter
        presenter.errorOutput = adapter
        return (viewController, eventSubject.eraseToAnyPublisher())
    }
}