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
        var totpProvider: AuthenticatorTOTPProvider
        var readAccounts: () -> AnyPublisher<[AuthenticatorAccountModel], Never>
        var delete: (_ accountID: UUID) -> AnyPublisher<Void, Error>
        var favourite: (_ account: UUID) -> AnyPublisher<Void, Error>
        var update: (_ account: AuthenticatorAccountModel) -> AnyPublisher<Void, Error>
        var refreshPublisher: AnyPublisher<Void, Never>
        var clockPublisher: AnyPublisher<Date, Never>
        var analytics: AuthenticatorAnalytics
    }

    static func list(dependencies: ListComposer.Dependencies) -> (AuthenticatorListViewController, ListEventPublisher) {
        let eventSubject = PassthroughSubject<ListEvent, Never>()
        let viewModel = AuthenticatorListViewModel()
        let presenterService = AuthenticatorListPresenterServiceAdapter(
            totpProvider: dependencies.totpProvider,
            clockPublisher: dependencies.clockPublisher,
            refreshPublisher: dependencies.refreshPublisher,
            readAccounts: dependencies.readAccounts,
            delete: dependencies.delete,
            favourite: dependencies.favourite,
            searchTextPublisher: viewModel.$searchText.eraseToAnyPublisher(),
            update: dependencies.update
        )
        let presenter = AuthenticatorListPresenter(service: presenterService, cycleLength: Constants.appCycleLength)
        presenterService.presenter = presenter
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
        let adapter = AuthenticatorListOutputAdapter(
            listViewController: viewController,
            presenter: presenter,
            listEventPublisher: eventSubject)
        presenter.output = adapter
        presenter.errorOutput = adapter
        let trackedEventPublisher = eventSubject.eraseToAnyPublisher().trackListEvents(analytics: dependencies.analytics)
        return (viewController, trackedEventPublisher)
    }
}
