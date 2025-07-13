//
//  GitHubSearchResponse.swift
//  GitSearch
//
//  Created by Suresh Kumar on 13/07/25.
//

import Foundation

struct GitHubUserSearchResponse: Decodable {
    let totalCount: Int
    let items: [GitHubUser]
    
    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case items
    }
}

struct GitHubSearchResponse: Decodable {
    let items: [GitHubUser]
}

struct GitHubUser: Decodable, Identifiable, Equatable {
    let id: Int
    let login: String
    let avatarUrl: String?
    let bio: String?
    let followers: Int?
    let publicRepos: Int?
    
    enum CodingKeys: String, CodingKey {
        case id
        case login
        case avatarUrl = "avatar_url"
        case bio
        case followers
        case publicRepos = "public_repos"
    }
    
    static func == (lhs: GitHubUser, rhs: GitHubUser) -> Bool {
        lhs.id == rhs.id
    }
}

struct GitHubRepository: Decodable, Identifiable, Equatable {
    let id: Int
    let name: String
    let description: String?
    let stargazersCount: Int
    let forksCount: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case stargazersCount = "stargazers_count"
        case forksCount = "forks_count"
    }
    
    static func == (lhs: GitHubRepository, rhs: GitHubRepository) -> Bool {
        lhs.id == rhs.id
    }
}
