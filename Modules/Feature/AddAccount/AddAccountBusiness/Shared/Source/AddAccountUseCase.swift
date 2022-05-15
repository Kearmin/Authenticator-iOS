//
//  AddAccountUseCase.swift
//  AddAccountBusiness
//
//  Created by Kertész Jenő Ármin on 2022. 04. 22..
//

import Foundation

public protocol AddAccountSaveService {
    func save(account: CreatAccountModel)
}

public enum AddAccountUseCaseErrors: Error, Equatable {
    case invalidURL(URL: String)
    case notSupportedOTPMethod(method: String)
    case notSupportedAlgorithm(algorithm: String)
    case notSupportedDigitCount(digit: String)
    case notSupportedPeriod(period: String)
}

public final class AddAccountUseCase {
    private let saveService: AddAccountSaveService

    public init(saveService: AddAccountSaveService) {
        self.saveService = saveService
    }

    public func createAccount(urlString: String) throws {
        let account = try parse(urlString: urlString)
        saveService.save(account: account)
    }
}

// MARK: - Private
private extension AddAccountUseCase {
    func parse(urlString: String) throws -> CreatAccountModel {
        guard let urlComponents = URLComponents(string: urlString), urlComponents.scheme?.lowercased() == "otpauth" else {
            throw AddAccountUseCaseErrors.invalidURL(URL: urlString)
        }
        let method = urlComponents.host ?? "empty"
        if method != "totp" {
            throw AddAccountUseCaseErrors.notSupportedOTPMethod(method: method)
        }
        return try CreatAccountModel(urlComponents: urlComponents)
    }
}

// MARK: - URLComponents
private extension URLComponents {
    struct QueryItemNotFoundError: Error { }

    func queryItemValue(for key: String) -> String? {
        queryItems?.first { $0.name.lowercased() == key.lowercased() }?.value
    }

    func lowerCasedQueryItemValue(for key: String) -> String? {
        queryItemValue(for: key)?.lowercased()
    }

    func lowerCasedQueryItemValue(for key: String, elseThrow error: Error) throws -> String {
        guard let queryItem = lowerCasedQueryItemValue(for: key) else {
            throw error
        }
        return queryItem
    }

    func lowerCasedQueryItemValue(matches value: String, forKey key: String, onError: (String) throws -> Void) rethrows -> String {
        let queryItemValue = lowerCasedQueryItemValue(for: key)
        if let queryItemValue = queryItemValue, queryItemValue != value {
            try onError(queryItemValue)
        }
        return queryItemValue ?? value
    }

    func getIssuer() throws -> String {
        guard let issuer = queryItemValue(for: "issuer") else {
            throw AddAccountUseCaseErrors.invalidURL(URL: url?.absoluteString ?? "")
        }
        return issuer
    }

    func getSecret() throws -> String {
        guard let secret = queryItemValue(for: "secret") else {
            throw AddAccountUseCaseErrors.invalidURL(URL: url?.absoluteString ?? "")
        }
        return secret
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
        let expectedDigits = "6"
        return try lowerCasedQueryItemValue(matches: expectedDigits, forKey: "digits", onError: { nonMatchingDigits in
            throw AddAccountUseCaseErrors.notSupportedDigitCount(digit: nonMatchingDigits)
        })
    }

    func getPeriod() throws -> String {
        let expectedPeriod = "30"
        return try lowerCasedQueryItemValue(matches: expectedPeriod, forKey: "period", onError: { nonMatchingPeriod in
            throw AddAccountUseCaseErrors.notSupportedPeriod(period: nonMatchingPeriod)
        })
    }

    func getAlgorithm() throws -> String {
        let expectedAlgorithm = "sha1"
        return try lowerCasedQueryItemValue(matches: expectedAlgorithm, forKey: "algorithm", onError: { nonMatchingAlgorithm in
            throw AddAccountUseCaseErrors.notSupportedAlgorithm(algorithm: nonMatchingAlgorithm)
        })
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
