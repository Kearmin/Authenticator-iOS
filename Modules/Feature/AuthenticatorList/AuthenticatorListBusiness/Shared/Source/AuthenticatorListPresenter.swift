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
    public let isFavourite: Bool

    public init(id: UUID, issuer: String, username: String, secret: String, isFavourite: Bool) {
        self.id = id
        self.issuer = issuer
        self.username = username
        self.secret = secret
        self.isFavourite = isFavourite
    }
}

public struct AuthenticatorListRowContent: Identifiable, Equatable {
    public var id: UUID
    public let issuer: String
    public let username: String
    public let TOTPCode: String
    public let isFavourite: Bool

    public init(id: UUID, issuer: String, username: String, TOTPCode: String, isFavourite: Bool) {
        self.id = id
        self.issuer = issuer
        self.username = username
        self.TOTPCode = TOTPCode
        self.isFavourite = isFavourite
    }
}

public struct AuthencticatorListSection: Equatable {
    public let title: String
    public let rowContent: [AuthenticatorListRowContent]

    public init(title: String, rowContent: [AuthenticatorListRowContent]) {
        self.title = title
        self.rowContent = rowContent
    }
}

public protocol AuthenticatorListPresenterService {
    func loadAccounts()
    func getTOTP(secret: String, timeInterval: Int, date: Date) -> String
    func deleteAccount(id: UUID)
    func move(_ account: UUID, with toAccount: UUID)
    func favourite(_ account: UUID)
}

public protocol AuthenticatorListViewOutput: AnyObject {
    func receive(countDown: String)
    func receive(sections: [AuthencticatorListSection])
}

public protocol AuthenticatorListErrorOutput: AnyObject {
    func receive(error: Error)
}

public final class AuthenticatorListPresenter {
    private var service: AuthenticatorListPresenterService
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

    public let title = "Authenticator"

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
            output?.receive(sections: sectionContent(from: models))
        } catch {
            errorOutput?.receive(error: error)
        }
    }

    public func favourite(id: UUID) {
        service.favourite(id)
    }

    public func move(fromOffset: Int, toOffset: Int) {
        guard
            fromOffset != toOffset,
            models.indices.contains(fromOffset),
            models.indices.contains(toOffset)
        else { return }
        service.move(models[fromOffset].id, with: models[toOffset].id)
    }

    public func delete(atOffset offset: Int) {
        guard models.indices.contains(offset) else {
            return
        }
        let id = models[offset].id
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
            TOTPCode: totp,
            isFavourite: model.isFavourite)
    }

    func rowContent(from models: [AuthenticatorAccountModel]) -> [AuthenticatorListRowContent] {
        models.map { rowContent(from: $0) }
    }

    func sectionContent(from models: [AuthenticatorAccountModel]) -> [AuthencticatorListSection] {
        var favourites: [AuthenticatorAccountModel] = []
        var other: [AuthenticatorAccountModel] = []
        for model in models {
            if model.isFavourite {
                favourites.append(model)
            } else {
                other.append(model)
            }
        }
        var sections: [AuthencticatorListSection] = []
        if !favourites.isEmpty {
            sections.append(AuthencticatorListSection(title: "Favourites", rowContent: rowContent(from: favourites)))
        }
        sections.append(AuthencticatorListSection(title: "Accounts", rowContent: rowContent(from: other)))
        return sections
    }

    func recalculateTOTPs() {
        output?.receive(sections: sectionContent(from: models))
    }
}

private extension Date {
    func countDownValue(cycleLength: Int) -> Int {
        cycleLength - (Int(self.timeIntervalSince1970) % cycleLength)
    }
}
