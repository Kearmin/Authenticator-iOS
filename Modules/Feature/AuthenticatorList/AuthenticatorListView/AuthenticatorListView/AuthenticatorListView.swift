//
//  AuthenticatorSwiftView.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 04. 21..
//

import SwiftUI

// 35KCTE3K23SWLHPYJLNATLZVWR765ZZ4

public struct AuthenticatorListView: View {
    @StateObject private var viewModel: AuthenticatorListViewModel

    public init(viewModel: AuthenticatorListViewModel) {
        _viewModel = .init(wrappedValue: viewModel)
    }

    public var body: some View {
        VStack(spacing: 10) {
            Text(viewModel.countDownSeconds)
                .font(.system(size: 60))
                .fontWeight(.bold)
            List {
                ForEach(viewModel.rows) { row in
                    HStack {
                        VStack(alignment: .leading, spacing: 5) {
                            Text(row.issuer)
                            Text(row.username)
                        }
                        Spacer()
                        Text(row.TOTPCode)
                            .font(.title)
                            .fontWeight(.semibold)
                            .kerning(1)
                    }
                    .swipeActions {
                        Button(role: .destructive) {
                            row.onTrailingSwipeAction()
                        } label: {
                            Text("Delete")
                        }
                    }
                }
            }
            .listStyle(.automatic)
        }
        .navigationTitle("Authenticator")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AuthenticatorListView_Previews: PreviewProvider {
    static var viewModel: AuthenticatorListViewModel {
        let viewModel = AuthenticatorListViewModel()
        viewModel.countDownSeconds = "30"
        viewModel.rows = [
            .init(id: UUID(), issuer: "Issuer", username: "Username", TOTPCode: "123456") { },
            .init(id: UUID(), issuer: "Issuer", username: "Username", TOTPCode: "123456") { },
            .init(id: UUID(), issuer: "Issuer", username: "Username", TOTPCode: "123456") { },
            .init(id: UUID(), issuer: "Issuer", username: "Username", TOTPCode: "123456") { }
        ]
        return viewModel
    }
    static var previews: some View {
        NavigationView {
            AuthenticatorListView(viewModel: viewModel)
        }
        NavigationView {
            AuthenticatorListView(viewModel: viewModel)
        }
        .preferredColorScheme(.dark)
    }
}
