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
    var receiveCurrentDate: ((Date) -> Void)? { get set }
    var cycleLength: Int { get }
    func deleteAccount(id: UUID) throws
}

public protocol AuthenticatorListPresenterDelegate: AnyObject {
    func receive(countDown: String)
    func receive(rows: [AuthenticatorListRowContent])
}

public final class AuthenticatorListPresenter {
    private var service: AuthenticatorListPresenterService
    private var subscriptions = Set<AnyCancellable>()
    private var latestDate: Date?
    private var models: [AuthenticatorAccountModel] = []

    public weak var output: AuthenticatorListPresenterDelegate? {
        didSet {
            // Get first value immediately
            guard let latestDate = latestDate else { return }
            output?.receive(countDown: "\(latestDate.countDownValue(cycleLength: service.cycleLength))")
        }
    }

    public init(service: AuthenticatorListPresenterService) {
        self.service = service
        setupSubscriptions()

    }

    public func load() {
        service.loadAccounts()
    }

    public func receive(result: Result<[AuthenticatorAccountModel], Error>) {
        do {
            let models = try result.get()
            self.models = models
            let rowContents = models.map { rowContent(from: $0) }
            output?.receive(rows: rowContents)
        } catch {
            print(error)
        }
    }

    public func deleteAccount(id: UUID) {
        do {
            try service.deleteAccount(id: id)
            models.removeAll(where: { $0.id == id })
            let rowContents = models.map { rowContent(from: $0) }
            output?.receive(rows: rowContents)
        } catch {
            print(error)
        }
    }
}

// MARK: - Private
private extension AuthenticatorListPresenter {
    func setupSubscriptions() {
        let cycleLength = service.cycleLength
        service.receiveCurrentDate = { [weak self] date in
            self?.latestDate = date
            let countDown = date.countDownValue(cycleLength: cycleLength)
            self?.output?.receive(countDown: "\(countDown)")
            if countDown == cycleLength {
                self?.recalculateTOTPs()
            }
        }
    }

    func rowContent(from model: AuthenticatorAccountModel) -> AuthenticatorListRowContent {
        let totp = service.getTOTP(
            secret: model.secret,
            timeInterval: service.cycleLength,
            date: latestDate ?? Date())

        return .init(id: model.id,
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
