//
//  AuthenticatorListPresenter.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 04. 22..
//

import Combine
import Foundation

public protocol AuthenticatorListBusinessService {
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

public final class AuthenticatorListBusiness {
    private var service: AuthenticatorListBusinessService
    private let modelUsecase: AuthenticatorListModelUseCase
    private let dateUsecase: AuthenticatorListDateUsecase
    private let presenter: AuthenticatorListPresenter

    public var output: AuthenticatorListViewOutput? {
        didSet {
            // Get first value immediately
            guard let countDown = dateUsecase.currentCountDown else { return }
            output?.receive(countDown: presenter.countDownString(from: countDown))
        }
    }
    public var errorOutput: AuthenticatorListErrorOutput?

    public init(service: AuthenticatorListBusinessService, cycleLength: Int) {
        self.service = service
        let modelUsecase = AuthenticatorListModelUseCase(service: service)
        let dateUsecase = AuthenticatorListDateUsecase(cycleLength: cycleLength)
        self.presenter = .init(calculateTOTP: { [unowned dateUsecase] secret in
            service.getTOTP(
                secret: secret,
                timeInterval: dateUsecase.cycleLength,
                date: dateUsecase.latestDate ?? Date())
        })
        self.modelUsecase = modelUsecase
        self.dateUsecase = dateUsecase
    }

    public func load() {
        modelUsecase.load()
    }

    public func refresh(date: Date = Date()) {
        if dateUsecase.needsRefresh(date: date) {
            sendFilteredOutput()
        }
    }

    public func receive(currentDate date: Date) {
        let result = dateUsecase.update(currentDate: date)
        output?.receive(countDown: presenter.countDownString(from: result.countDown))
        if result.needsRefresh {
            sendFilteredOutput()
        }
    }

    public func receive(result: Result<[AuthenticatorAccountModel], Error>) {
        do {
            let models = try result.get()
            modelUsecase.receive(models: models)
            sendFilteredOutput()
        } catch {
            errorOutput?.receive(error: error)
        }
    }

    public func update(id: UUID, issuer: String?, username: String?) {
        modelUsecase.update(id: id, issuer: issuer, username: username)
    }

    public func favourite(id: UUID) {
        modelUsecase.favourite(id: id)
    }

    public func delete(id: UUID) {
        modelUsecase.delete(id: id)
    }

    public func delete(atOffset offset: Int) {
        modelUsecase.delete(atOffset: offset)
    }

    public func filter(by text: String) {
        modelUsecase.filter(by: text)
        sendFilteredOutput()
    }

    public func receive(error: Error) {
        errorOutput?.receive(error: error)
    }
}

// MARK: - Private
private extension AuthenticatorListBusiness {
    func sendFilteredOutput() {
        let filteredModels = modelUsecase.filteredModels
        let content = presenter.sectionContent(from: filteredModels)
        output?.receive(content: content)
    }
}
