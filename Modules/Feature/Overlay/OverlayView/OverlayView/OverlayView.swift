//
//  OverLayView.swift
//  OverlayView
//
//  Created by Kertész Jenő Ármin on 2022. 05. 17..
//

import SwiftUI

public struct OverlayView: View {
    public var imageName: String
    private var isDebug: Bool
    private var onUnlockDidPress: () -> Void

    public init(imageName: String, onUnlockDidPress: @escaping () -> Void = { }) {
        self.imageName = imageName
        self.isDebug = false
        self.onUnlockDidPress = onUnlockDidPress
    }

    fileprivate init() { // swiftlint:disable:this strict_fileprivate
        imageName = ""
        onUnlockDidPress = { }
        isDebug = true
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
                Text("Unlock")
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
