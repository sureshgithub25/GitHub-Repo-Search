//
//  UserSearchView.swift
//  GitSearch
//
//  Created by Suresh Kumar on 13/07/25.
//

import SwiftUI

struct UserSearchView: View {
    @StateObject private var viewModel: UserSearchViewModel = .init(githubService: GitHubService())
    
    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $viewModel.searchQuery, placeholder: "Search GitHub users")
                
                if viewModel.isLoading && viewModel.users.isEmpty {
                    ProgressView()
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                } else if viewModel.users.isEmpty && !viewModel.searchQuery.isEmpty {
                    Text("No users found")
                        .foregroundColor(.gray)
                } else {
                    List(viewModel.users) { user in
                        NavigationLink(destination: UserDetailView(viewModel: UserRepositoriesViewModel(user: user, gitHubService: viewModel.githubService))) {
                            UserRow(user: user)
                                .onAppear {
                                    viewModel.loadMoreIfNeeded(currentItem: user)
                                }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
                
                Spacer()
            }
            .navigationTitle("GitHub Search")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    ThemeToggleButton()
                }
            }
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    var placeholder: String
    
    var body: some View {
        HStack {
            TextField(placeholder, text: $text)
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal)
                .autocapitalization(.none)
                .disableAutocorrection(true)
        }
        .padding(.vertical, 8)
    }
}

struct UserRow: View {
    let user: GitHubUser
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 8) {
            if let avatarUrl = user.avatarUrl, let url = URL(string: avatarUrl) {
                CachedAsyncImage(url: url)
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
            }
            
            VStack(alignment: .leading) {
                Text(user.login)
                    .font(.headline)
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                
                if let bio = user.bio {
                    Text(bio)
                        .font(.caption)
                        .foregroundColor(colorScheme == .dark ? .gray : .secondary)
                }
            }
        }
    }
}

struct ThemeToggleButton: View {
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        Button(action: {
            themeManager.toggleTheme()
        }) {
            Text("Change Theme")
                .foregroundStyle(themeManager.isDarkMode ? .white : .black)
            Image(systemName: themeManager.isDarkMode ? "moon.fill" : "sun.max.fill")
                .imageScale(.large)
        }
    }
}
