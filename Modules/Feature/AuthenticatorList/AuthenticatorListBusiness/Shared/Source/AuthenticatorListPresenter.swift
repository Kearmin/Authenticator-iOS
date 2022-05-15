//
//  AuthenticatorListPresenter.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 04. 22..
//

import Combine
import Foundation

public struct AuthenticatorAccountModel: Codable {
    public let id: UUID
    public let issuer: String
    public let username: String
    public let secret: String

    public init(id: UUID, issuer: String, username: String, secret: String) {
        self.id = id
        self.issuer = issuer
        self.username = username
        self.secret = secret
    }
}

public struct AuthenticatorListRowContent: Identifiable, Equatable {
    public var id: UUID
    public let issuer: String
    public let username: String
    public let TOTPCode: String

    public init(id: UUID, issuer: String, username: String, TOTPCode: String) {
        self.id = id
        self.issuer = issuer
        self.username = username
        self.TOTPCode = TOTPCode
    }
}

public protocol AuthenticatorListPresenterService {
    func loadAccounts()
    func getTOTP(secret: String, timeInterval: Int, date: Date) -> String
    func deleteAccount(id: UUID)
}

public protocol AuthenticatorListViewOutput: AnyObject {
    func receive(countDown: String)
    func receive(rows: [AuthenticatorListRowContent])
}

public protocol AuthenticatorListErrorOutput: AnyObject {
    func receive(error: Error)
}

public final class AuthenticatorListPresenter {
    private var service: AuthenticatorListPresenterService
    private var subscriptions = Set<AnyCancellable>()
    private var latestDate: Date?
    private var models: [AuthenticatorAccountModel] = []

    let cycleLength: Int

    public var output: AuthenticatorListViewOutput? {
        didSet {
            // Get first value immediately
            guard let latestDate = latestDate else { return }
            output?.receive(countDown: "\(latestDate.countDownValue(cycleLength: cycleLength))")
        }
    }
    public var errorOutput: AuthenticatorListErrorOutput?


    public init(service: AuthenticatorListPresenterService, cycleLength: Int) {
        self.service = service
        self.cycleLength = cycleLength
    }

    public func load() {
        service.loadAccounts()
    }

    public func refresh(date: Date = Date()) {
        guard let latestDate = latestDate else { return }
        let countDown = latestDate.countDownValue(cycleLength: cycleLength)
        if latestDate.timeIntervalSince1970 + Double(countDown) > date.timeIntervalSince1970 { return }
        self.latestDate = date
        recalculateTOTPs()
    }

    public func receive(currentDate date: Date) {
        latestDate = date
        let countDown = date.countDownValue(cycleLength: cycleLength)
        output?.receive(countDown: "\(countDown)")
        if countDown == cycleLength {
            recalculateTOTPs()
        }
    }

    public func receive(result: Result<[AuthenticatorAccountModel], Error>) {
        do {
            let models = try result.get()
            self.models = models
            let rowContents = models.map { rowContent(from: $0) }
            output?.receive(rows: rowContents)
        } catch {
            errorOutput?.receive(error: error)
        }
    }

    public func deleteAccount(id: UUID) {
        service.deleteAccount(id: id)
    }

    public func receive(error: Error) {
        errorOutput?.receive(error: error)
    }
}

// MARK: - Private
private extension AuthenticatorListPresenter {
    func rowContent(from model: AuthenticatorAccountModel) -> AuthenticatorListRowContent {
        let totp = service.getTOTP(
            secret: model.secret,
            timeInterval: cycleLength,
            date: latestDate ?? Date())

        return .init(
            id: model.id,
            issuer: model.issuer,
            username: model.username,
            TOTPCode: totp)
    }

    func recalculateTOTPs() {
        let rowContents = models.map { rowContent(from: $0) }
        output?.receive(rows: rowContents)
    }
}

private extension Date {
    func countDownValue(cycleLength: Int) -> Int {
        cycleLength - (Int(self.timeIntervalSince1970) % cycleLength)
    }
}
