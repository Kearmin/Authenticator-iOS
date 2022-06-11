//
//  EditAccountFlow.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 06. 06..
//

import UIKit
import AuthenticatorListBusiness

class EditAccountFlow {
    private let account: AuthenticatorListRowContent
    private let source: UIViewController?
    private let didFinishUpdate: (_ issuer: String?, _ username: String?) -> Void

    init(account: AuthenticatorListRowContent, source: UIViewController?, didFinishUpdate: @escaping (_ issuer: String?, _ username: String?) -> Void) {
        self.account = account
        self.didFinishUpdate = didFinishUpdate
        self.source = source
    }

    func start() {
        guard let source = source else { return }

        let alert = UIAlertController(title: "Edit account", message: "", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Issuer"
            textField.text = self.account.issuer
        }
        alert.addTextField { textField in
            textField.placeholder = "Username"
            textField.text = self.account.username
        }
        alert.addAction(.init(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(.init(title: "Finish", style: .default, handler: { [self] _ in
            self.didFinishUpdate(alert.textFields?[0].text, alert.textFields?[1].text)
        }))
        onMain {
            source.present(alert, animated: true)
        }
    }
}
