//
//  AddAccountDelegateComposition.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 04. 24..
//

import Resolver
import AddAccountBusiness
import UIKitNavigator

final class AddAccountDelegateComposition: AddAccountComposerDelegate {
    let listComposer: AuthenticatorListComposer
    let navigator: UIKitNavigator

    init(listComposer: AuthenticatorListComposer, navigator: UIKitNavigator) {
        self.listComposer = listComposer
        self.navigator = navigator
    }

    func shouldCloseComponent(_ addAccountComposer: AddAccountComposer) {
        navigator.dismiss(viewController: addAccountComposer)
    }

    func startUpDidFail(_ addAccountComposer: AddAccountComposer) {
        navigator.presentSimpleAlert(
            title: "Scanning not supported",
            message: "Your device does not support scanning a QR codes. Please use a device with a camera.",
            source: addAccountComposer) { [navigator] _ in
                navigator.dismiss(viewController: addAccountComposer)
            }
    }

    func qrCodeParseDidFail(_ addAccountComposer: AddAccountComposer, completion: @escaping () -> Void) {
        navigator.presentSimpleAlert(
            title: "Invalid QR code",
            message: "The captured QR code format is not accepted",
            source: addAccountComposer) { _ in
                completion()
            }
    }

    func didCreateNewAccount(_ addAccountComposer: AddAccountComposer, account: CreatAccountModel) {
        listComposer.reload()
        navigator.dismiss(viewController: addAccountComposer)
    }
}

final class AddAccountDelegateComposition2: AddAccountComposerDelegate {
    let listComposer: AuthenticatorListComposer2
    let navigator: UIKitNavigator

    init(listComposer: AuthenticatorListComposer2, navigator: UIKitNavigator) {
        self.listComposer = listComposer
        self.navigator = navigator
    }

    func shouldCloseComponent(_ addAccountComposer: AddAccountComposer) {
        navigator.dismiss(viewController: addAccountComposer)
    }

    func startUpDidFail(_ addAccountComposer: AddAccountComposer) {
        navigator.presentSimpleAlert(
            title: "Scanning not supported",
            message: "Your device does not support scanning a QR codes. Please use a device with a camera.",
            source: addAccountComposer) { [navigator] _ in
                navigator.dismiss(viewController: addAccountComposer)
            }
    }

    func qrCodeParseDidFail(_ addAccountComposer: AddAccountComposer, completion: @escaping () -> Void) {
        navigator.presentSimpleAlert(
            title: "Invalid QR code",
            message: "The captured QR code format is not accepted",
            source: addAccountComposer) { _ in
                completion()
            }
    }

    func didCreateNewAccount(_ addAccountComposer: AddAccountComposer, account: CreatAccountModel) {
        listComposer.load()
        navigator.dismiss(viewController: addAccountComposer)
    }
}
