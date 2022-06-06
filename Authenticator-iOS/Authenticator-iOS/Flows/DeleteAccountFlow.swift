//
//  DeleteAccountFlow.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 06. 06..
//

import UIKit

class DeleteAccountFlow {
    let source: UIViewController?
    let didPressDelete: () -> Void

    internal init(source: UIViewController?, didPressDelete: @escaping () -> Void) {
        self.source = source
        self.didPressDelete = didPressDelete
    }

    func start() {
        guard let source = source else { return }
        let alert = UIAlertController(
            title: "Confirm",
            message: "Do you really want to delete this account?",
            preferredStyle: .alert)
        alert.addAction(.init(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(.init(title: "Delete", style: .destructive, handler: { _ in
            self.didPressDelete()
        }))
        onMain {
            source.present(alert, animated: true)
        }
    }
}
