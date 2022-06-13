//
//  AuthenticatorListPresenterServiceAdapter.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 05. 14..
//

import Repository
import AuthenticatorListBusiness
import Combine

class AuthenticatorListPresenterServiceAdapter: AuthenticatorListBusinessService {
    private let totpProvider: AuthenticatorTOTPProvider
    private let currentTimeSubject = CurrentValueSubject<Date, Never>(Date())
    private var subscriptions = Set<AnyCancellable>()
    private var subjectSubscription: AnyCancellable?
    private var refreshSubscription: AnyCancellable?

    private var clockPublisher: AnyPublisher<Date, Never>
    private var readAccounts: () -> AnyPublisher<[AuthenticatorAccountModel], Never>
    private var delete: (_ accountID: UUID) -> AnyPublisher<Void, Error>
    private var favourite: (_ accountID: UUID) -> AnyPublisher<Void, Error>
    private var update: (_ account: AuthenticatorAccountModel) -> AnyPublisher<Void, Error>
    private var searchTextPublisher: AnyPublisher<String, Never>

    weak var presenter: AuthenticatorListBusiness? {
        didSet {
            subjectSubscription = currentTimeSubject
                .sink(receiveValue: { [weak presenter] date in
                    presenter?.receive(currentDate: date)
                })
        }
    }

    init(totpProvider: AuthenticatorTOTPProvider,
         clockPublisher: AnyPublisher<Date, Never>,
         refreshPublisher: AnyPublisher<Void, Never>,
         readAccounts: @escaping () -> AnyPublisher<[AuthenticatorAccountModel], Never>,
         delete: @escaping (_ accountID: UUID) -> AnyPublisher<Void, Error>,
         favourite: @escaping (_ accountID: UUID) -> AnyPublisher<Void, Error>,
         searchTextPublisher: AnyPublisher<String, Never>,
         update: @escaping (_ account: AuthenticatorAccountModel) -> AnyPublisher<Void, Error>
    ) {
        self.totpProvider = totpProvider
        self.clockPublisher = clockPublisher
        self.readAccounts = readAccounts
        self.delete = delete
        self.favourite = favourite
        self.searchTextPublisher = searchTextPublisher
        self.update = update

        clockPublisher
            .subscribe(currentTimeSubject)
            .store(in: &subscriptions)

        refreshSubscription = refreshPublisher
            .sink(receiveValue: { [weak self] in
                self?.loadAccounts()
            })

        searchTextPublisher
            .dropFirst()
            .debounce(for: .seconds(0.3), scheduler: RunLoop.main)
            .sink { [weak self] searchText in
                self?.presenter?.filter(by: searchText)
            }
            .store(in: &subscriptions)
    }

    func loadAccounts() {
        readAccounts()
            .sink { [presenter] accounts in
                presenter?.receive(result: .success(accounts))
            }
            .store(in: &subscriptions)
    }

    func getTOTP(secret: String, timeInterval: Int, date: Date) -> String {
        totpProvider.totp(secret: secret, date: date, digits: 6, timeInterval: timeInterval, algorithm: .sha1) ?? "Error"
    }

    func deleteAccount(id: UUID) {
        executeOperation(operation: delete(id))
    }

    func favourite(_ account: UUID) {
        executeOperation(operation: favourite(account))
    }

    func update(_ account: AuthenticatorAccountModel) {
        executeOperation(operation: update(account))
    }

    func executeOperation(operation: AnyPublisher<Void, Error>) {
        operation
            .sink { [presenter] completion in
                if case let .failure(error) = completion {
                    presenter?.receive(error: error)
                }
            } receiveValue: { _ in }
            .store(in: &subscriptions)
    }
}
