//
//  AuthenticatorListModelUseCase.swift
//  AuthenticatorListBusiness
//
//  Created by Kertész Jenő Ármin on 2022. 06. 13..
//

import Foundation

final class AuthenticatorListModelUseCase {
    let service: AuthenticatorListBusinessService
    private var models: [AuthenticatorAccountModel] = []
    private var currentFilter: String?

    init(service: AuthenticatorListBusinessService) {
        self.service = service
    }

    var filteredModels: [AuthenticatorAccountModel] {
        var filteredModels: [AuthenticatorAccountModel]
        if let filterText = currentFilter?.lowercased() {
            filteredModels = models.filter { model in
                model.username.lowercased().contains(filterText) || model.issuer.lowercased().contains(filterText)
            }
        } else {
            filteredModels = models
        }
        return filteredModels
    }

    func load() {
        service.loadAccounts()
    }

    public func receive(models: [AuthenticatorAccountModel]) {
        self.models = models
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
    }
}
