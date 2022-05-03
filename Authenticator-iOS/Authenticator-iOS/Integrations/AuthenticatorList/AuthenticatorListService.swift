//
//  AuthenticatorListService.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 04. 22..
//

import AuthenticatorListBusiness
import Foundation
import SwiftOTP
import Resolver
import AccountRepository
import Clock

final class TimerAuthenticatorListPresenterService: AuthenticatorListPresenterService {
    private let clock: Clock = Resolver.resolve()
    private let repository: AccountRepository = Resolver.resolve()
    private let totpProvider: AuthenticatorTOTPProvider = Resolver.resolve()
    private let analitycs: AuthenticatorAnalytics = Resolver.resolve()

    weak var presenter: AuthenticatorListPresenter?

    var receiveCurrentDate: ((Date) -> Void)? {
        didSet {
            guard !clock.containsObserver(self) else { return }
            if receiveCurrentDate != nil {
                clock.addObserver(self)
            } else {
                clock.removeObserver(self)
            }
        }
    }

    var cycleLength: Int = 30

    deinit {
        clock.removeObserver(self)
    }

    func loadAccounts() {
        let accounts = repository.readAccounts()
        let presenterAccounts = accounts.map {
            AuthenticatorAccountModel(
                id: $0.id,
                issuer: $0.issuer,
                username: $0.username,
                secret: $0.secret)
        }
        presenter?.receive(result: .success(presenterAccounts))
    }

    func deleteAccount(id: UUID) throws {
        try repository.delete(accountID: id)
        analitycs.logEvent(name: "AuthenticatorAccountDeleted")
    }

    func getTOTP(secret: String, timeInterval: Int, date: Date) -> String {
        totpProvider.getTOTP(secret: secret, date: date) ?? "error"
    }
}

extension TimerAuthenticatorListPresenterService: ClockObserver {
    func handle(currentDate: Date) {
        Queues.generalBackgroundQueue.async {
            self.receiveCurrentDate?(currentDate)
        }
    }
}
