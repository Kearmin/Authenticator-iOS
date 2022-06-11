//
//  OverLayView.swift
//  OverlayView
//
//  Created by Kertész Jenő Ármin on 2022. 05. 17..
//

import SwiftUI

public extension OverlayView {
    struct Configuration {
        let unlockText: String

        public init(unlockText: String) {
            self.unlockText = unlockText
        }
    }
}

public struct OverlayView: View {
    public var imageName: String
    private var isDebug: Bool
    private var onUnlockDidPress: () -> Void
    private let configuration: Configuration

    public init(
        imageName: String,
        configuration: Configuration,
        onUnlockDidPress: @escaping () -> Void = { }
    ) {
        self.imageName = imageName
        self.isDebug = false
        self.configuration = configuration
        self.onUnlockDidPress = onUnlockDidPress
    }

    fileprivate init() { // swiftlint:disable:this strict_fileprivate
        imageName = ""
        onUnlockDidPress = { }
        isDebug = true
        configuration = .init(unlockText: "unlock")
    }

    public var body: some View {
        VStack {
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .background(isDebug ? .red : .clear)
                .padding(.horizontal)
                .padding(.bottom, 150)
            Button {
                onUnlockDidPress()
            } label: {
                Text(configuration.unlockText)
                    .font(.headline)
                    .fontWeight(.bold)
            }
        }
    }
}

struct OverLayView_Previews: PreviewProvider {
    static var previews: some View {
        OverlayView()
        OverlayView()
            .preferredColorScheme(.dark)
    }
}
