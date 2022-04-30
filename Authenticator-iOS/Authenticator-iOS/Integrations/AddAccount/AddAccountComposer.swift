//
//  AddAccount+Init.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 04. 23..
//

import Foundation
import AddAccountView
import AddAccountBusiness
import UIKit

protocol AddAccountComposerDelegate: AnyObject {
    func shouldCloseComponent(_ addAccountComposer: AddAccountComposer)
    func startUpDidFail(_ addAccountComposer: AddAccountComposer)
    func qrCodeParseDidFail(_ addAccountComposer: AddAccountComposer, completion: @escaping () -> Void)
    func didCreateNewAccount(_ addAccountComposer: AddAccountComposer, account: CreatAccountModel)
}

final class AddAccountComposer: UIViewController {
    let addAccoutView: AddAccountView = AddAccountView(frame: .zero, objectTypes: [.qr])
    let useCase: AddAccountUseCase
    var delegate: AddAccountComposerDelegate?

    init(useCase: AddAccountUseCase) {
        self.useCase = useCase
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func loadView() {
        view = addAccoutView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = .init(
            title: "Done",
            style: .done,
            target: self,
            action: #selector(didPressDoneButton))
        addAccoutView.delegate = self
    }

    @objc
    private func didPressDoneButton() {
        delegate?.shouldCloseComponent(self)
    }
}

extension AddAccountComposer: AddAccountViewDelegate {
    func didFindQRCode(code: String) {
        do {
            let account = try useCase.createAccount(urlString: code)
            delegate?.didCreateNewAccount(self, account: account)
        } catch {
            delegate?.qrCodeParseDidFail(self) { [addAccoutView] in
                addAccoutView.resumeSession()
            }
        }
    }

    func failedToStart() {
        delegate?.startUpDidFail(self)
    }
}
