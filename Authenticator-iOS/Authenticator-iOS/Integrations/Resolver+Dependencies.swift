//
//  Resolver+Dependencies.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 05. 14..
//

import Foundation
import Resolver
import Combine

import FileSystemPersistentStorage
import AccountRepository
import UIKit

extension Resolver {
    static func registerDependencies() {
        register {
            LogAnalytics()
        }
        .implements(AuthenticatorAnalytics.self)
        .scope(.application)

//        register(SegmentAnalytics.self) {
//            SegmentAnalytics()
//        }
//        .implements(AuthenticatorAnalytics.self)
//        .scope(.application)

        register(AppEventSubject.self) {
            PassthroughSubject<AppEvent, Never>()
        }
        .scope(.application)

        register(AppEventPublisher.self) { resolver in
            let subject: AppEventSubject = resolver.resolve()
            return subject.eraseToAnyPublisher()
        }
        .scope(.application)

        register {
            JSONFileSystemPersistance<[Account]>(fileName: "accounts", queue: Queues.fileIOBackgroundQueue)
        }
        .scope(.cached)

        register { resolver in
            AccountRepository(provider: resolver.resolve())
        }
        .scope(.cached)

        register(TOTPProvider.self) {
            AuthenticatorTOTPProvider()
        }
    }
}
