//
//  AuthenticatorSwiftView.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 04. 21..
//

import SwiftUI

public struct AuthenticatorListView: View {
    @StateObject public var viewModel: AuthenticatorListViewModel

    public var onMove: (_ fromOffsets: IndexSet, _ toOffset: Int) -> Void
    public var onDelete: (_ atOffsets: IndexSet) -> Void
    public var onFavouriteDidPress: (UUID) -> Void

    public init(
        viewModel: AuthenticatorListViewModel,
        onMove: @escaping (_ source: IndexSet, _ destination: Int) -> Void,
        onDelete: @escaping (_ indexes: IndexSet) -> Void,
        onFavouriteDidPress: @escaping (UUID) -> Void
    ) {
        _viewModel = .init(wrappedValue: viewModel)
        self.onMove = onMove
        self.onDelete = onDelete
        self.onFavouriteDidPress = onFavouriteDidPress
    }

    public var body: some View {
        VStack(spacing: 10) {
            Text(viewModel.countDownSeconds)
                .font(.system(size: 60))
                .fontWeight(.bold)
            List {
                ForEach(viewModel.sections) { section in
                    Section(section.title) {
                        ForEach(section.rows) { row in
                            authenticatorListRow(row)
                        }
                        .onMove(perform: onMove)
                        .onDelete(perform: onDelete)
                    }
                }
            }
            .toolbar {
                EditButton()
            }
            .listStyle(.sidebar)
        }
        .navigationBarTitleDisplayMode(.inline)
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
            Image(systemName: row.isFavourite ? "star.fill" : "star")
                .resizable()
                .frame(width: 35, height: 35)
                .foregroundColor(.yellow)
                .onTapGesture {
                    onFavouriteDidPress(row.id)
                }
        }
        .padding(.trailing)
    }
}

struct AuthenticatorListView_Previews: PreviewProvider {
    static var viewModel: AuthenticatorListViewModel {
        let viewModel = AuthenticatorListViewModel(
            countDownSeconds: "30",
            sections: [
                .init(title: "Favourites", rows: [
                    .init(id: UUID(), issuer: "Issuer", username: "Username", TOTPCode: "123456", isFavourite: true),
                    .init(id: UUID(), issuer: "Issuer", username: "Username", TOTPCode: "123456", isFavourite: true),
                    .init(id: UUID(), issuer: "Issuer", username: "Username", TOTPCode: "123456", isFavourite: true),
                    .init(id: UUID(), issuer: "Issuer", username: "Username", TOTPCode: "123456", isFavourite: true)
                ]),
                .init(title: "Accounts", rows: [
                    .init(id: UUID(), issuer: "Issuer", username: "Username", TOTPCode: "123456", isFavourite: false),
                    .init(id: UUID(), issuer: "Issuer", username: "Username", TOTPCode: "123456", isFavourite: false),
                    .init(id: UUID(), issuer: "Issuer", username: "Username", TOTPCode: "123456", isFavourite: false),
                    .init(id: UUID(), issuer: "Issuer", username: "Username", TOTPCode: "123456", isFavourite: false)
                ])
            ])
        return viewModel
    }
    static var previews: some View {
        NavigationView {
            AuthenticatorListView(
                viewModel: viewModel,
                onMove: { _, _  in },
                onDelete: { _ in },
                onFavouriteDidPress: { _ in })
        }
        NavigationView {
            AuthenticatorListView(
                viewModel: viewModel,
                onMove: { _, _  in },
                onDelete: { _ in },
                onFavouriteDidPress: { _ in })
        }
        .preferredColorScheme(.dark)
    }
}
