//
//  AddAccountView.swift
//  AddAccountView
//
//  Created by Kertész Jenő Ármin on 2022. 05. 14..
//

import AVFoundation
import UIKit

public protocol AddAccountViewDelegate: AnyObject {
    func didFindQRCode(code: String)
    func failedToStart()
}

public final class AddAccountView: UIView {
    private lazy var metaDataOutput: AVCaptureMetadataOutput = {
        let metaDataOutput = AVCaptureMetadataOutput()
        metaDataOutput.connection(with: .video)?.isEnabled = true
        return metaDataOutput
    }()

    private lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.videoGravity = .resizeAspect
        return layer
    }()

    private let captureDevice: AVCaptureDevice? = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
    private lazy var session = AVCaptureSession()

    private let objectTypes: [AVMetadataObject.ObjectType]
    public var delegate: AddAccountViewDelegate?

    public init(frame: CGRect, objectTypes: [AVMetadataObject.ObjectType]) {
        self.objectTypes = objectTypes
        super.init(frame: frame)
        beginSession()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        session.stopRunning()
    }

    private func beginSession() {
        guard let captureDevice = captureDevice,
              let deviceInput = try? AVCaptureDeviceInput(device: captureDevice),
              session.canAddInput(deviceInput),
              session.canAddOutput(metaDataOutput) else {
            delegate?.failedToStart()
            return
        }
        session.addInput(deviceInput)
        session.addOutput(metaDataOutput)
        metaDataOutput.setMetadataObjectsDelegate(self, queue: .main)
        metaDataOutput.metadataObjectTypes = objectTypes
        layer.masksToBounds = true
        layer.addSublayer(previewLayer)
        previewLayer.frame = bounds
        previewLayer.videoGravity = .resizeAspectFill
        session.startRunning()
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer.frame = bounds
    }

    public func resumeSession() {
        guard !session.isRunning else { return }
        session.startRunning()
    }
}

extension AddAccountView: AVCaptureMetadataOutputObjectsDelegate {
    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard
            let readableObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
            let stringValue = readableObject.stringValue
        else {
            return
        }
        session.stopRunning()
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        delegate?.didFindQRCode(code: stringValue)
    }
}
