//
//  Navigator+AuthenticatorListComposerDelegate.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 04. 24..
//

import Resolver
import UIKitNavigator

extension UIKitNavigator: AuthenticatorListComposerDelegate {
    func didPressAddAccountButton(_ authenticatorListViewComposer: AuthenticatorListComposer) {
        let addAccountComposer = AddAccountComposer()
        addAccountComposer.delegate = AddAccountDelegateComposition(listComposer: authenticatorListViewComposer, navigator: self)
        presentFullScreenEmbeddedInNavigationController(view: addAccountComposer, source: authenticatorListViewComposer)
    }
}
