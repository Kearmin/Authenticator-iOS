//
//  AuthenticatorListPresenterServiceAdapter.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 05. 14..
//

import AccountRepository
import AuthenticatorListBusiness
import Combine

class AuthenticatorListPresenterServiceAdapter: AuthenticatorListPresenterService {
    private let totpProvider: TOTPProvider
    private let currentTimeSubject = CurrentValueSubject<Date, Never>(Date())
    private var subscriptions = Set<AnyCancellable>()
    private var subjectSubscription: AnyCancellable?
    private var appEventSubscription: AnyCancellable?

    var readAccounts: () -> AnyPublisher<[Account], Never>
    var delete: (_ accountID: UUID) -> AnyPublisher<Void, Error>

    weak var presenter: AuthenticatorListPresenter? {
        didSet {
            subjectSubscription = currentTimeSubject
                .sink(receiveValue: { [weak presenter] date in
                    presenter?.receive(currentDate: date)
                })
        }
    }

    init(totpProvider: TOTPProvider,
         appEventPublisher: AnyPublisher<AppEvent, Never>,
         readAccounts: @escaping () -> AnyPublisher<[Account], Never>,
         delete: @escaping (_ accountID: UUID) -> AnyPublisher<Void, Error>
    ) {
        self.totpProvider = totpProvider
        self.readAccounts = readAccounts
        self.delete = delete

        Timer
            .publish(every: 1, on: .current, in: .common)
            .autoconnect()
            .receive(on: Queues.generalBackgroundQueue)
            .subscribe(currentTimeSubject)
            .store(in: &subscriptions)

        appEventSubscription = appEventPublisher
            .filter(.newAccountCreated)
            .receive(on: Queues.generalBackgroundQueue)
            .sink(receiveValue: { [weak self] in
                self?.loadAccounts()
            })
    }

    func loadAccounts() {
        readAccounts()
            .subscribe(on: Queues.generalBackgroundQueue)
            .map { $0.map(\.authenticatorAccountModel) }
            .sink { [presenter] accounts in
                presenter?.receive(result: .success(accounts))
            }
            .store(in: &subscriptions)
    }

    func getTOTP(secret: String, timeInterval: Int, date: Date) -> String {
        totpProvider.totp(secret: secret, date: date, digits: 6, timeInterval: timeInterval, algorithm: .sha1) ?? "Error"
    }

    func deleteAccount(id: UUID) {
        delete(id)
            .subscribe(on: Queues.generalBackgroundQueue)
            .sink { [presenter] completion in
                if case let .failure(error) = completion {
                    presenter?.receive(error: error)
                }
            } receiveValue: { [weak self] _ in
                self?.loadAccounts()
            }
            .store(in: &subscriptions)
    }
}

extension Account {
    var authenticatorAccountModel: AuthenticatorAccountModel {
        .init(id: id, issuer: issuer, username: username, secret: secret)
    }
}
