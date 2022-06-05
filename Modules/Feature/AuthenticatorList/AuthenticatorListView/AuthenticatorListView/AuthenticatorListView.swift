//
//  AuthenticatorSwiftView.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 04. 21..
//

import SwiftUI
import Combine

public struct AuthenticatorListView: View {
    @StateObject public var viewModel: AuthenticatorListViewModel

    public init(
        viewModel: AuthenticatorListViewModel
    ) {
        _viewModel = .init(wrappedValue: viewModel)
    }

    public var body: some View {
        VStack(spacing: 10) {
            HStack {
                TextField("Search", text: $viewModel.searchText)
                    .textFieldStyle(.roundedBorder)
                Text(viewModel.countDownSeconds)
                    .font(.system(size: 40))
                    .fontWeight(.bold)
                    .frame(width: 60)
            }
            .padding(.horizontal)
            List {
                ForEach(viewModel.sections) { section in
                    Section(section.title) {
                        ForEach(section.rows) { row in
                            authenticatorListRow(row)
                        }
                    }
                }
            }
            .listStyle(.automatic)
        }
    }

    public func authenticatorListRow(_ row: AuthenticatorListRow) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(row.issuer)
                    .font(.body)
                Text(row.TOTPCode)
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .kerning(1)
                Text(row.username)
                    .font(.body)
            }
            Spacer()
        }
        .padding(.trailing)
        .contentShape(Rectangle())
        .onTapGesture {
            row.onDidPress()
        }
        .swipeActions(edge: .leading) {
            Button() {
                print("Edit: \(row.username)")
            } label: {
                Text("Edit")
            }
            .tint(.cyan)
        }
        .swipeActions {
            Button(action: row.onDeletePress) {
                Image(systemName: "trash.fill")
            }
            .tint(.red)
        }
        .swipeActions {
            Button(action: row.onFavouritePress) {
                Image(systemName: row.isFavourite ? "star.slash.fill" : "star.fill")
            }
            .tint(.yellow)
        }
    }
}

struct AuthenticatorListView_Previews: PreviewProvider {
    static var viewModel: AuthenticatorListViewModel {
        let viewModel = AuthenticatorListViewModel(
            countDownSeconds: "30",
            sections: [
                .init(title: "Favourites", rows: [
                    .init(
                        id: UUID(),
                        issuer: "Issuer",
                        username: "Username",
                        TOTPCode: "123456",
                        isFavourite: true,
                        onFavouritePress: {},
                        onDeletePress: {},
                        onDidPress: {}),
                    .init(
                        id: UUID(),
                        issuer: "Issuer",
                        username: "Username",
                        TOTPCode: "123456",
                        isFavourite: true,
                        onFavouritePress: {},
                        onDeletePress: {},
                        onDidPress: {})
                ]),
                .init(title: "Accounts", rows: [
                    .init(
                        id: UUID(),
                        issuer: "Issuer",
                        username: "Username",
                        TOTPCode: "123456",
                        isFavourite: false,
                        onFavouritePress: {},
                        onDeletePress: {},
                        onDidPress: {}),
                    .init(
                        id: UUID(),
                        issuer: "Issuer",
                        username: "Username",
                        TOTPCode: "123456",
                        isFavourite: false,
                        onFavouritePress: {},
                        onDeletePress:




                            {},
                        onDidPress: {})
                ])
            ])
        return viewModel
    }
    static var previews: some View {
        NavigationView {
            AuthenticatorListView(
                viewModel: viewModel)
        }
        NavigationView {
            AuthenticatorListView(
                viewModel: viewModel)
        }
        .preferredColorScheme(.dark)
    }
}
