//
//  ListComposer.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 05. 14..
//

import Foundation
import AuthenticatorListView
import AuthenticatorListBusiness
import Repository
import Combine
import Resolver

typealias ListFactory = () -> (AuthenticatorListViewController, ListEventPublisher)

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
        let businessFacadeService = AuthenticatorListBusinessFacadeServiceAdapter(
            totpProvider: dependencies.totpProvider,
            clockPublisher: dependencies.clockPublisher,
            refreshPublisher: dependencies.refreshPublisher,
            readAccounts: dependencies.readAccounts,
            delete: dependencies.delete,
            favourite: dependencies.favourite,
            searchTextPublisher: viewModel.$searchText.eraseToAnyPublisher(),
            update: dependencies.update
        )
        let businessFacade = AuthenticatorListBusiness(service: businessFacadeService, cycleLength: Constants.appCycleLength)
        businessFacadeService.facade = businessFacade
        let viewConfiguration = AuthenticatorListView.Configuration(searchPlaceholder: "Search".localized, editText: "Edit".localized)
        let rootView = AuthenticatorListView(viewModel: viewModel, configuration: viewConfiguration)
        let viewController = AuthenticatorListViewController(
            viewModel: viewModel,
            rootview: rootView,
            didPressAddAccount: { _ in eventSubject.send(.addAccountDidPress) },
            onViewDidLoad: {
                eventSubject.send(.viewDidLoad)
                businessFacade.load()
            })
        viewController.title = "Authenticator".localized
        let adapter = AuthenticatorListOutputAdapter(
            listViewController: viewController,
            businessFacade: businessFacade,
            listEventPublisher: eventSubject)
        businessFacade.output = adapter
        businessFacade.errorOutput = adapter
        let trackedEventPublisher = eventSubject.eraseToAnyPublisher().trackListEvents(analytics: dependencies.analytics)
        return (viewController, trackedEventPublisher)
    }
}
