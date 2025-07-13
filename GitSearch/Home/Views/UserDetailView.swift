//
//  UserDetailView.swift
//  GitSearch
//
//  Created by Suresh Kumar on 13/07/25.
//

import SwiftUI
import Combine

struct UserDetailView: View {
    @StateObject var viewModel: UserRepositoriesViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top) {
                    if let avatarUrl = viewModel.user.avatarUrl, let url = URL(string: avatarUrl) {
                        CachedAsyncImage(url: url)
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(viewModel.user.login)
                            .font(.title)
                        
                        if let bio = viewModel.user.bio {
                            Text(bio)
                                .font(.body)
                        }
                        
                        HStack(spacing: 16) {
                            if let followers = viewModel.user.followers {
                                Label("\(followers)", systemImage: "person.2")
                            }
                            
                            if let publicRepos = viewModel.user.publicRepos {
                                Label("\(publicRepos)", systemImage: "folder")
                            }
                        }
                    }
                }
                
                Divider()
                
                Text("Repositories")
                    .font(.headline)
                
                if viewModel.isLoading && viewModel.repositories.isEmpty {
                    ProgressView()
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.repositories) { repo in
                            RepositoryRow(repository: repo)
                                .onAppear {
                                    viewModel.loadMoreRepositoriesIfNeeded(currentItem: repo)
                                }
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle(viewModel.user.login)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct RepositoryRow: View {
    let repository: GitHubRepository
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(repository.name)
                .font(.headline)
            
            if let description = repository.description {
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            HStack(spacing: 16) {
                Label("\(repository.stargazersCount)", systemImage: "star")
                Label("\(repository.forksCount)", systemImage: "arrow.triangle.branch")
                Spacer()
            }
            .font(.caption)
        }
        .padding(EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12))
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

extension RepositoryRow: Equatable {
    static func == (lhs: RepositoryRow, rhs: RepositoryRow) -> Bool {
        return lhs.repository == rhs.repository
    }
}
