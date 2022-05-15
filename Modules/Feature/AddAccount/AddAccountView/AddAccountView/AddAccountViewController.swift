//
//  AddAccountViewController.swift
//  AddAccountView
//
//  Created by Kertész Jenő Ármin on 2022. 04. 22..
//

import AVFoundation
import UIKit

public final class AddAccountViewController: UIViewController {
    public let addAccountView: AddAccountView
    private let doneDidPress: (AddAccountViewController) -> Void
    private let didFindQRCode: (AddAccountViewController, _ code: String) -> Void
    private let _failedToStart: (AddAccountViewController) -> Void

    public override func loadView() {
        view = addAccountView
    }

    public init(
        objectTypes: [AVMetadataObject.ObjectType] = [.qr],
        doneDidPress: @escaping (AddAccountViewController) -> Void,
        didFindQRCode: @escaping (AddAccountViewController, String) -> Void,
        failedToStart: @escaping (AddAccountViewController) -> Void
    ) {
        addAccountView = AddAccountView(frame: .zero, objectTypes: objectTypes)
        self.doneDidPress = doneDidPress
        self.didFindQRCode = didFindQRCode
        _failedToStart = failedToStart
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
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension AddAccountViewController: AddAccountViewDelegate {
    public func didFindQRCode(code: String) {
        didFindQRCode(self, code)
    }

    public func failedToStart() {
        _failedToStart(self)
    }
}
