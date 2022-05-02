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
        guard let urlComponents = URLComponents(string: urlString),
              urlComponents.scheme?.lowercased() == "otpauth",
              let issuer = urlComponents.lowerCasedQueryItemValue(for: "issuer"),
              let secret = urlComponents.lowerCasedQueryItemValue(for: "secret")
        else {
            throw AddAccountUseCaseErrors.invalidURL
        }
        guard let method = urlComponents.host, method == "totp" else {
                throw AddAccountUseCaseErrors.notSupportedOTPMethod
        }
        try validateNonEssentialQueryItems(urlComponents: urlComponents)
        let username = username(from: urlComponents)
        return CreatAccountModel(issuer: issuer, secret: secret, username: username)
    }

    func username(from urlComponents: URLComponents) -> String {
        if urlComponents.path.contains(":") {
            let substring = urlComponents.path
                .drop { $0 != ":" }
                .dropFirst()
            return String(substring)
        } else {
            return String(urlComponents.path.dropFirst())
        }
    }

    func validateNonEssentialQueryItems(urlComponents: URLComponents) throws {
        try urlComponents.queryItemValueIfExists(
            matches: "sha1",
            forKey: "algorithm",
            elseThrow: AddAccountUseCaseErrors.notSupportedAlgorithm)
        try urlComponents.queryItemValueIfExists(
            matches: "30",
            forKey: "period",
            elseThrow: AddAccountUseCaseErrors.notSupportedPeriod)
        try urlComponents.queryItemValueIfExists(
            matches: "6",
            forKey: "digits",
            elseThrow: AddAccountUseCaseErrors.notSupportedDigitCount)
    }
}

private extension URLComponents {
    func lowerCasedQueryItemValue(for key: String) -> String? {
        let queryItem = queryItems?.first { $0.name.lowercased() == key.lowercased() }
        return queryItem?.value
    }

    func queryItemValueIfExists(matches value: String, forKey key: String, elseThrow error: Error) throws {
        guard let queryItemValue = lowerCasedQueryItemValue(for: key) else { return }
        if queryItemValue != value {
            throw error
        }
    }
}
