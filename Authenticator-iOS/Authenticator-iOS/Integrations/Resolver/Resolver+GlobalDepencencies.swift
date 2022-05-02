//
//  Resolver+GlobalDepencencies.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 04. 24..
//

import Resolver
import FileSystemPersistentStorage
import AccountRepository
import AuthenticatorListBusiness
import AddAccountBusiness
import SwiftOTP
import UIKitNavigator
import Clock

extension Resolver {
    static func registerAppDependencies() {
        registerCoreDependencies()
        registerDebugInfrastructureDependencies()
//        registerMockInfrastructureDebendencies()
    }
}

extension Resolver {
    static public func registerCoreDependencies() {
        register(AppEventObservable.self) {
            AppEventObservable()
        }
        .scope(.application)

        register(OverLayViewController.self) {
            let vc = OverLayViewController()
            vc.modalPresentationStyle = .overCurrentContext
            return vc
        }
        .scope(.application)

        register(Clock.self) {
            Clock()
        }
        .scope(.application)

        register(SwiftOTPProvider.self) {
            SwiftOTPProvider()
        }
        .implements(AuthenticatorTOTPProvider.self)
        .scope(.application)

        register(FireBaseAnalitycsAdapter.self) {
            FireBaseAnalitycsAdapter()
        }
        .implements(AuthenticatorAnalytics.self)
        .scope(.application)

        register(UIKitNavigator.self) { resolver in
            let appEventObservable: AppEventObservable = resolver.resolve()
            let navigator = UIKitNavigator()
            appEventObservable.observeWeakly(navigator)
            return navigator
        }
        .implements(AuthenticatorListComposerDelegate.self)
        .implements(AddAccountComposerDelegate.self)
        .scope(.application)
    }

    static func registerDebugInfrastructureDependencies() {
        register(JSONFileSystemPersistance<[Account]>.self) {
            JSONFileSystemPersistance(fileName: "accounts", queue: Queues.fileIOBackgroundQueue)
        }
        .implements(AccountRepositoryProvider.self)
        .scope(.cached)

        register(AccountRepository.self) { resolver in
            AccountRepository(provider: resolver.resolve(), queue: Queues.fileIOBackgroundQueue)
        }
        .implements(AddAccountSaveService.self)
        .scope(.cached)

        register(TimerAuthenticatorListPresenterService.self) { resolver in
            TimerAuthenticatorListPresenterService()
        }
        .implements(AuthenticatorListPresenterService.self)

        register(AuthenticatorListPresenter.self) {
            .init(service: resolve())
        }
    }
}
