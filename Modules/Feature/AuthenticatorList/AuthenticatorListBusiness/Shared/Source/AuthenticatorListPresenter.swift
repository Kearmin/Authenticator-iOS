//
//  AuthenticatorListPresenter.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 04. 22..
//

import Combine
import Foundation

public protocol AuthenticatorListPresenterService {
    func loadAccounts()
    func getTOTP(secret: String, timeInterval: Int, date: Date) -> String
    func deleteAccount(id: UUID)
    func favourite(_ account: UUID)
    func update(_ account: AuthenticatorAccountModel)
}

public protocol AuthenticatorListViewOutput: AnyObject {
    func receive(countDown: String)
    func receive(content: AuthenticatorListContent)
}

public protocol AuthenticatorListErrorOutput: AnyObject {
    func receive(error: Error)
}

public final class AuthenticatorListPresenter {
    private var service: AuthenticatorListPresenterService
    private var latestDate: Date?
    private var models: [AuthenticatorAccountModel] = []
    private var currentFilter: String?

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
            sendFilteredOutput()
        } catch {
            errorOutput?.receive(error: error)
        }
    }

    public func update(id: UUID, issuer: String?, username: String?) {
        guard let issuer = issuer,
              let username = username,
               let account = models.first(where: { $0.id == id })
        else {
            return
        }
        if account.issuer == issuer && account.username == username {
            return
        }
        let newAccount = AuthenticatorAccountModel(
            id: account.id,
            issuer: issuer,
            username: username,
            secret: account.secret,
            isFavourite: account.isFavourite,
            createdAt: account.createdAt)
        service.update(newAccount)
    }

    public func favourite(id: UUID) {
        service.favourite(id)
    }

    public func delete(id: UUID) {
        service.deleteAccount(id: id)
    }

    public func delete(atOffset offset: Int) {
        guard models.indices.contains(offset) else {
            return
        }
        let id = models[offset].id
        service.deleteAccount(id: id)
    }

    public func filter(by text: String) {
        currentFilter = text.isEmpty ? nil : text
        sendFilteredOutput()
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
        sendFilteredOutput()
    }

    func sendFilteredOutput() {
        var filteredModels: [AuthenticatorAccountModel]
        if let filterText = currentFilter?.lowercased() {
            filteredModels = models.filter { model in
                model.username.lowercased().contains(filterText) || model.issuer.lowercased().contains(filterText)
            }
        } else {
            filteredModels = models
        }
        output?.receive(content: sectionContent(from: filteredModels))
    }
}

private extension Date {
    func countDownValue(cycleLength: Int) -> Int {
        cycleLength - (Int(self.timeIntervalSince1970) % cycleLength)
    }
}
