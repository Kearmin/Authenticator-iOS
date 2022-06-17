//
//  AddAccountViewController.swift
//  AddAccountView
//
//  Created by Kertész Jenő Ármin on 2022. 04. 22..
//

import AVFoundation
import UIKit

open class AddAccountViewController: UIViewController {
    public let addAccountView: AddAccountView
    private let doneDidPress: (AddAccountViewController) -> Void

    public var reference: AnyObject?

    public override func loadView() {
        view = addAccountView
    }

    public init(
        addAccountView: AddAccountView,
        doneDidPress: @escaping (AddAccountViewController) -> Void
    ) {
        self.addAccountView = addAccountView
        self.doneDidPress = doneDidPress
        super.init(nibName: nil, bundle: nil)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(handleDoneButtonDidPress))
    }

    @objc
    private func handleDoneButtonDidPress() {
        doneDidPress(self)
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
