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
import Combine
import Resolver


enum ListComposer {
    struct Dependencies {
        var totpProvider: TOTPProvider
        var readAccounts: () -> AnyPublisher<[AuthenticatorAccountModel], Never>
        var delete: (_ accountID: UUID) -> AnyPublisher<Void, Error>
        var moveAccounts: (_ from: UUID, _ to: UUID) -> AnyPublisher<Void, Error>
        var favourite: (_ account: UUID) -> AnyPublisher<Void, Error>
        var refreshPublisher: AnyPublisher<Void, Never>
    }

    static func list(dependencies: ListComposer.Dependencies) -> (AuthenticatorListViewController, ListEventPublisher) {
        let eventSubject = PassthroughSubject<ListEvent, Never>()
        let presenterService = AuthenticatorListPresenterServiceAdapter(
            totpProvider: dependencies.totpProvider,
            refreshPublisher: dependencies.refreshPublisher,
            readAccounts: dependencies.readAccounts,
            delete: dependencies.delete,
            swap: dependencies.moveAccounts,
            favourite: dependencies.favourite)
        let presenter = AuthenticatorListPresenter(service: presenterService, cycleLength: Constants.appCycleLength)
        presenterService.presenter = presenter
        let viewModel = AuthenticatorListViewModel()
        let rootView = AuthenticatorListView(
            viewModel: viewModel)
        let viewController = AuthenticatorListViewController(
            viewModel: viewModel,
            rootview: rootView,
            didPressAddAccount: { _ in eventSubject.send(.addAccountDidPress) },
            onViewDidLoad: {
                eventSubject.send(.viewDidLoad)
                presenter.load()
            })
        viewController.title = presenter.title
        let adapter = AuthenticatorListOutputAdapter(listViewController: viewController, presenter: presenter)
        presenter.output = adapter
        presenter.errorOutput = adapter
        return (viewController, eventSubject.eraseToAnyPublisher())
    }
}
