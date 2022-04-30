//
//  AddAccountComposer+init.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 04. 24..
//

import AddAccountBusiness
import Resolver

extension AddAccountComposer {
    convenience init() {
        let useCase = AddAccountUseCase(service: Resolver.resolve())
        self.init(useCase: useCase)
    }
}
