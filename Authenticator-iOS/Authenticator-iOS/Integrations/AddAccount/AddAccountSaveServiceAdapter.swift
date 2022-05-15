//
//  AddAccountSaveServiceAdapter.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 05. 15..
//

import Combine
import AddAccountBusiness
import AccountRepository
import AddAccountView

class AddAccountSaveServiceAdapter: AddAccountSaveService {
    let createAccountPublisher: (Account) -> AnyPublisher<Void, Error>
    let eventSubject: PassthroughSubject<AddAccountEvent, Never>
    var createAccountSubscription: AnyCancellable?

    init(createAccountPublisher: @escaping (Account) -> AnyPublisher<Void, Error>, eventSubject: PassthroughSubject<AddAccountEvent, Never>) {
        self.createAccountPublisher = createAccountPublisher
        self.eventSubject = eventSubject
    }

    func save(account: CreatAccountModel) {
        let account = Account(
            id: UUID(),
            issuer: account.issuer,
            secret: account.secret,
            username: account.username)
        createAccountSubscription = createAccountPublisher(account)
            .sink(receiveCompletion: { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.eventSubject.send(.qrCodeReadDidFail(error: error))
                }
            }, receiveValue: { [weak self] _ in
                self?.eventSubject.send(.didCreateAccount(account: account))
            })
    }
}
