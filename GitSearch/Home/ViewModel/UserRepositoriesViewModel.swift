//
//  UserRepositoriesViewModel.swift
//  GitSearch
//
//  Created by Suresh Kumar on 13/07/25.
//

import Foundation
import Combine

final class UserRepositoriesViewModel: ObservableObject {
    @Published var repositories: [GitHubRepository] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var user: GitHubUser
    
    private let gitHubService: GitHubServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    private var currentPage = 1
    private let perPage = 20
    
    init(user: GitHubUser, gitHubService: GitHubServiceProtocol) {
        self.user = user
        self.gitHubService = gitHubService
        loadRepositories()
    }
    
    func loadRepositories() {
        isLoading = true
        errorMessage = nil
        
        gitHubService.getUserRepositories(username: user.login, page: currentPage, perPage: perPage)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                
                if case .failure(let error) = completion {
                    if self?.repositories.isEmpty ?? false {
                        self?.errorMessage = error.message
                    }
                }
            } receiveValue: { [weak self] repositories in
                self?.repositories.append(contentsOf: repositories)
                self?.currentPage += 1
            }
            .store(in: &cancellables)
    }
    
    func loadMoreRepositoriesIfNeeded(currentItem: GitHubRepository?) {
        guard let currentItem = currentItem else {
            loadRepositories()
            return
        }
        
        let thresholdIndex = repositories.index(repositories.endIndex, offsetBy: -5)
        if repositories.firstIndex(where: { $0.id == currentItem.id }) == thresholdIndex {
            loadRepositories()
        }
    }
}
