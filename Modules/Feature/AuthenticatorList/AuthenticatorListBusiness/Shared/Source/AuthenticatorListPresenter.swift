//
//  AuthenticatorListPresenter.swift
//  AuthenticatorListBusiness
//
//  Created by Kertész Jenő Ármin on 2022. 06. 13..
//

import Foundation

final class AuthenticatorListPresenter {
    private let calculateTOTP: (_ secret: String) -> String

    init(calculateTOTP: @escaping (_ secret: String) -> String) {
        self.calculateTOTP = calculateTOTP
    }

    func countDownString(from countDown: Int) -> String {
        "\(countDown)"
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

    private func rowContent(from model: AuthenticatorAccountModel) -> AuthenticatorListRowContent {
        let totp = calculateTOTP(model.secret)

        return .init(
            id: model.id,
            issuer: model.issuer,
            username: model.username,
            TOTPCode: totp,
            isFavourite: model.isFavourite)
    }

    private func rowContent(from models: [AuthenticatorAccountModel]) -> [AuthenticatorListRowContent] {
        models.map { rowContent(from: $0) }
    }
}
