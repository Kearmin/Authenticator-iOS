//
//  ListLoaderStub.swift
//  Authenticator-iOSIntegrationTests
//
//  Created by Kertész Jenő Ármin on 2022. 06. 11..
//

import Combine
import AuthenticatorListBusiness

class ListLoaderStub {
    lazy var readAccounts: () -> AnyPublisher<[AuthenticatorAccountModel], Never> = readAccountsLoader.startRequest
    var readAccountsLoader = LoaderStub<[AuthenticatorAccountModel], Never>()
    var readAccountsCallCount: Int { readAccountsLoader.requestCallCount }

    var clockSubject = PassthroughSubject<Date, Never>()
    lazy var clock: AnyPublisher<Date, Never> = clockSubject.eraseToAnyPublisher()

    lazy var delete: (UUID) -> AnyPublisher<Void, Error> = { [unowned self] id in
        deleteCallIDs.append(id)
        return self.deleteLoader.startRequest()
    }
    var deleteCallIDs: [UUID] = []
    var deleteLoader = LoaderStub<Void, Error>()
    var deleteCallCount: Int { deleteLoader.requestCallCount }

    lazy var favourite: (UUID) -> AnyPublisher<Void, Error> = { [unowned self] id in
        self.favouriteCallIDs.append(id)
        return favouriteLoader.startRequest()
    }
    var favouriteLoader = LoaderStub<Void, Error>()
    var favouriteCallIDs: [UUID] = []
    var favouriteCallCount: Int { favouriteLoader.requestCallCount }

    var refresh: AnyPublisher<Void, Never> {
        refreshSubject.eraseToAnyPublisher()
    }
    var refreshSubject = PassthroughSubject<Void, Never>()

    lazy var update: (AuthenticatorAccountModel) -> AnyPublisher<Void, Error> = { [unowned self] model in
        self.updateCallItems.append(model)
        return self.updateLoader.startRequest()
    }
    var updateCallItems: [AuthenticatorAccountModel] = []
    var updateLoader = LoaderStub<Void, Error>()
    var updateCallCount: Int { updateLoader.requestCallCount }
}
