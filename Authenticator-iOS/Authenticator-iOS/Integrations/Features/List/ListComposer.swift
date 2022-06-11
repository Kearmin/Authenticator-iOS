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
        let totpProvider: AuthenticatorTOTPProvider
        let readAccounts: () -> AnyPublisher<[AuthenticatorAccountModel], Never>
        let delete: (_ accountID: UUID) -> AnyPublisher<Void, Error>
        let favourite: (_ account: UUID) -> AnyPublisher<Void, Error>
        let update: (_ account: AuthenticatorAccountModel) -> AnyPublisher<Void, Error>
        let refreshPublisher: AnyPublisher<Void, Never>
        let clockPublisher: AnyPublisher<Date, Never>
        let analytics: AuthenticatorAnalytics
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
        let rootView = AuthenticatorListView(viewModel: viewModel)
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
