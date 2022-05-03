//
//  AddAccountUseCase.swift
//  AddAccountBusiness
//
//  Created by Kertész Jenő Ármin on 2022. 04. 22..
//

import Foundation

public protocol AddAccountSaveService {
    func save(account: CreatAccountModel) throws
}

public enum AddAccountUseCaseErrors: Error {
    case invalidURL
    case notSupportedOTPMethod
    case notSupportedAlgorithm
    case notSupportedDigitCount
    case notSupportedPeriod
}

public final class AddAccountUseCase {
    private let saveService: AddAccountSaveService

    public init(saveService: AddAccountSaveService) {
        self.saveService = saveService
    }

    @discardableResult
    public func createAccount(urlString: String) throws -> CreatAccountModel {
        let account = try parse(urlString: urlString)
        try saveService.save(account: account)
        return account
    }
}

// MARK: - Private
private extension AddAccountUseCase {
    func parse(urlString: String) throws -> CreatAccountModel {
        guard let urlComponents = URLComponents(string: urlString), urlComponents.scheme?.lowercased() == "otpauth" else {
            throw AddAccountUseCaseErrors.invalidURL
        }
        guard let method = urlComponents.host, method == "totp" else {
            throw AddAccountUseCaseErrors.notSupportedOTPMethod
        }
        return try CreatAccountModel(urlComponents: urlComponents)
    }
}

// MARK: - URLComponents
private extension URLComponents {
    func lowerCasedQueryItemValue(for key: String) -> String? {
        let queryItem = queryItems?.first { $0.name.lowercased() == key.lowercased() }
        return queryItem?.value
    }

    func lowerCasedQueryItemValue(for key: String, elseThrow error: Error) throws -> String {
        guard let queryItem = lowerCasedQueryItemValue(for: key) else {
            throw error
        }
        return queryItem
    }

    func lowerCasedQueryItemValue(matches value: String, forKey key: String, elseThrow error: Error) throws -> String {
        guard let queryItemValue = lowerCasedQueryItemValue(for: key) else { return value }
        if queryItemValue != value { throw error }
        return queryItemValue
    }

    func getIssuer() throws -> String {
        try lowerCasedQueryItemValue(for: "issuer", elseThrow: AddAccountUseCaseErrors.invalidURL)
    }

    func getSecret() throws -> String {
        try lowerCasedQueryItemValue(for: "secret", elseThrow: AddAccountUseCaseErrors.invalidURL)
    }

    func getUsername() -> String {
        if path.contains(":") {
            let substring = path
                .drop { $0 != ":" }
                .dropFirst()
            return String(substring)
        } else {
            return String(path.dropFirst())
        }
    }

    func getDigits() throws -> String {
        try lowerCasedQueryItemValue(
            matches: "6",
            forKey: "digits",
            elseThrow: AddAccountUseCaseErrors.notSupportedDigitCount)
    }

    func getPeriod() throws -> String {
        try lowerCasedQueryItemValue(
            matches: "30",
            forKey: "period",
            elseThrow: AddAccountUseCaseErrors.notSupportedPeriod)
    }

    func getAlgorithm() throws -> String {
        try lowerCasedQueryItemValue(
            matches: "sha1",
            forKey: "algorithm",
            elseThrow: AddAccountUseCaseErrors.notSupportedAlgorithm)
    }
}

// MARK: - CreateAccountModel
extension CreatAccountModel {
    init(urlComponents: URLComponents) throws {
        self.init(
            issuer: try urlComponents.getIssuer(),
            secret: try urlComponents.getSecret(),
            username: urlComponents.getUsername(),
            digits: try urlComponents.getDigits(),
            period: try urlComponents.getPeriod(),
            algorithm: try urlComponents.getAlgorithm())
    }
}
