//
//  AuthenticationList+Init.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 04. 22..
//

import AuthenticatorListView
import AuthenticatorListBusiness
import Foundation
import Resolver

extension AuthenticatorListComposer {
    convenience init() {
        let viewModel = AuthenticatorListViewModel()
        let authenticatorListView = AuthenticatorListView(viewModel: viewModel)
        let service = TimerAuthenticatorListPresenterService()
        let presenter = AuthenticatorListPresenter(service: service)
        service.presenter = presenter
        self.init(
            rootView: authenticatorListView,
            viewModel: viewModel,
            presenter: presenter,
            appEventObservable: Resolver.resolve())
    }
}
