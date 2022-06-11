//
//  AuthenticatorSwiftView.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 04. 21..
//

import SwiftUI
import Combine

public extension AuthenticatorListView {
    struct Configuration {
        public let searchPlaceholder: String
        public let editText: String

        public init(searchPlaceholder: String, editText: String) {
            self.searchPlaceholder = searchPlaceholder
            self.editText = editText
        }
    }
}

public struct AuthenticatorListView: View {
    @StateObject public var viewModel: AuthenticatorListViewModel
    private let configuration: Configuration

    public init(
        viewModel: AuthenticatorListViewModel,
        configuration: Configuration
    ) {
        _viewModel = .init(wrappedValue: viewModel)
        self.configuration = configuration
    }

    public var body: some View {
        ZStack {
            VStack(spacing: 10) {
                HStack {
                    TextField(configuration.searchPlaceholder, text: $viewModel.searchText)
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
            if let toast = viewModel.toast {
                VStack {
                    Spacer()
                    Text(toast)
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(4)
                        .background(Color.blue)
                        .cornerRadius(5)
                }
                .offset(x: 0, y: -25)
                .transition(.opacity)
                .zIndex(1)
            }
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
            Button(action: row.onEditPress) {
                Text(configuration.editText)
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
                        onDidPress: {},
                        onEditPress: {}),
                    .init(
                        id: UUID(),
                        issuer: "Issuer",
                        username: "Username",
                        TOTPCode: "123456",
                        isFavourite: true,
                        onFavouritePress: {},
                        onDeletePress: {},
                        onDidPress: {},
                        onEditPress: {})
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
                        onDidPress: {},
                        onEditPress: {}),
                    .init(
                        id: UUID(),
                        issuer: "Issuer",
                        username: "Username",
                        TOTPCode: "123456",
                        isFavourite: false,
                        onFavouritePress: {},
                        onDeletePress: {},
                        onDidPress: {},
                        onEditPress: {})
                ])
            ])
        viewModel.toast = "Copied to clipboard"
        return viewModel
    }

    static var config: AuthenticatorListView.Configuration {
        .init(searchPlaceholder: "Search", editText: "Edot")
    }

    static var previews: some View {
        NavigationView {
            AuthenticatorListView(
                viewModel: viewModel,
                configuration: config)
            .navigationBarTitleDisplayMode(.inline)
        }
        NavigationView {
            AuthenticatorListView(
                viewModel: viewModel,
                configuration: config)
            .navigationBarTitleDisplayMode(.inline)
        }
        .preferredColorScheme(.dark)
    }
}
