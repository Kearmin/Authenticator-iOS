//
//  BiometricAuthenticator.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 06. 12..
//

import Combine
import LocalAuthentication

class BiometricAuthenticator {
    func biometricAuthentication() -> AnyPublisher<Bool, Error> {
        Future { completion in
            let context = LAContext()
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "Unlock your accounts".localized) { success, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                completion(.success(true))
            }
        }
        .eraseToAnyPublisher()
    }
}
