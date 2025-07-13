//
//  Untitled.swift
//  GitSearch
//
//  Created by Suresh Kumar on 13/07/25.
//

import Foundation
import Combine

final class UserSearchViewModel: ObservableObject {
    @Published var searchQuery: String = ""
    @Published var users: [GitHubUser] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    private var currentPage = 1
    private let perPage = 10
    var canLoadMore = true
    let githubService: GitHubServiceProtocol
    private var cancellables: Set<AnyCancellable> = []
    
    init(githubService: GitHubServiceProtocol) {
        self.githubService = githubService
        
        $searchQuery
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .filter { !$0.isEmpty }
            .sink { [weak self] query in
                self?.searchUsers(query: query, reset: true)
            }
            .store(in: &cancellables)
    }
    
    func searchUsers(query: String, reset: Bool = false) {
        if reset {
            users.removeAll()
            currentPage = 1
            canLoadMore = true
        }
        
        guard !query.isEmpty, !isLoading, canLoadMore else { return }
        
        isLoading = true
        githubService.searchUsers(query: query, page: currentPage, perPage: perPage)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    if self?.users.isEmpty ?? false {
                        self?.errorMessage = error.message
                    }
                }
            } receiveValue: { [weak self] newUsers in
                self?.users.append(contentsOf: newUsers)
                self?.currentPage += 1
                self?.canLoadMore = newUsers.count == self?.perPage
            }
            .store(in: &cancellables)
    }
    
    func loadMoreIfNeeded(currentItem: GitHubUser?) {
        guard let currentItem = currentItem else {
            searchUsers(query: searchQuery)
            return
        }
        
        let thresholdIndex = users.index(users.endIndex, offsetBy: -5)
        if users.firstIndex(where: { $0.id == currentItem.id }) == thresholdIndex {
            searchUsers(query: searchQuery)
        }
    }
}
