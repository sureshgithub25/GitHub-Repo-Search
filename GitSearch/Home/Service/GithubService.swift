//
//  GithubService.swift
//  GitSearch
//
//  Created by Suresh Kumar on 13/07/25.
//

import Foundation
import Combine

protocol GitHubServiceProtocol {
    func searchUsers(query: String, page: Int, perPage: Int) -> AnyPublisher<[GitHubUser], APIError>
    func getUserRepositories(username: String, page: Int, perPage: Int) -> AnyPublisher<[GitHubRepository], APIError>
}

final class GitHubService: GitHubServiceProtocol {
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol = NetworkService.shared) {
        self.networkService = networkService
    }
    
    func searchUsers(query: String, page: Int, perPage: Int) -> AnyPublisher<[GitHubUser], APIError> {
        let endpoint = GitHubEndpoint.searchUser(query: query, page: page, perPage: perPage)
        
        return networkService.request(endpoint)
            .tryMap { (response: GitHubUserSearchResponse) in
                guard !response.items.isEmpty || page == 1 else {
                    throw APIError.noResults
                }
                return response.items
            }
            .mapError { error in
                error as? APIError ?? .decodingError(error)
            }
            .eraseToAnyPublisher()
    }
    
    func getUserRepositories(username: String, page: Int, perPage: Int) -> AnyPublisher<[GitHubRepository], APIError> {
        let endpoint = GitHubEndpoint.getUserRepos(username: username, page: page, perPage: perPage)
        
        return networkService.request(endpoint)
            .tryMap { (repositories: [GitHubRepository]) in
                guard !repositories.isEmpty || page == 1 else {
                    throw APIError.noResults
                }
                return repositories
            }
            .mapError { error in
                error as? APIError ?? .decodingError(error)
            }
            .eraseToAnyPublisher()
    }
}

