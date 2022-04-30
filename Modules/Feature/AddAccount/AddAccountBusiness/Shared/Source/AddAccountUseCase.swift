//
//  AddAccountUseCase.swift
//  AddAccountBusiness
//
//  Created by Kertész Jenő Ármin on 2022. 04. 22..
//

import Foundation

public protocol AddAccountService {
    func save(account: CreatAccountModel) throws
}

public struct CreatAccountModel: Equatable {
    public let issuer: String
    public let secret: String
    public let username: String

    public init(issuer: String, secret: String, username: String) {
        self.issuer = issuer
        self.secret = secret
        self.username = username
    }
}

public enum AddAccountUseCaseErrors: Error {
    case invalidURL
    case notSupportedOTPMethod
    case notSupportedAlgorithm
    case notSupportedDigitCount
    case notSupportedPeriod
}

public final class AddAccountUseCase {
    private let service: AddAccountService

    public init(service: AddAccountService) {
        self.service = service
    }

    private func parse(urlString: String) throws -> CreatAccountModel {
        guard let urlComponents = URLComponents(string: urlString),
              urlComponents.scheme?.lowercased() == "otpauth",
              let issuer = urlComponents.queryItems?.first(where: { $0.name.lowercased() == "issuer" })?.value,
              let secret = urlComponents.queryItems?.first(where: { $0.name.lowercased() == "secret" })?.value
        else {
            throw AddAccountUseCaseErrors.invalidURL
        }
        if let method = urlComponents.host {
            if !method.lowercased().contains("totp") {
                throw AddAccountUseCaseErrors.notSupportedOTPMethod
            }
        }
        if let algorithm = urlComponents.queryItems?.first(where: { $0.name.lowercased() == "algorithm" })?.value {
            if algorithm.lowercased() != "sha1" {
                throw AddAccountUseCaseErrors.notSupportedAlgorithm
            }
        }
        if let digits = urlComponents.queryItems?.first(where: { $0.name.lowercased() == "digits" })?.value {
            if digits.lowercased() != "6" {
                throw AddAccountUseCaseErrors.notSupportedDigitCount
            }
        }
        if let period = urlComponents.queryItems?.first(where: { $0.name.lowercased() == "period" })?.value {
            if period.lowercased() != "30" {
                throw AddAccountUseCaseErrors.notSupportedPeriod
            }
        }
        let username: String = {
            if urlComponents.path.contains(":") {
                let substring = urlComponents.path
                    .drop(while: { $0 != ":" })
                    .dropFirst()
                return String(substring)
            } else {
                return String(urlComponents.path.dropFirst())
            }
        }()
        return .init(
            issuer: issuer,
            secret: secret,
            username: username)
    }

    @discardableResult
    public func createAccount(urlString: String) throws -> CreatAccountModel {
        let account = try parse(urlString: urlString)
        try service.save(account: account)
        return account
    }
}
