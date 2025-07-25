//
//  NetworkService.swift
//  GitSearch
//
//  Created by Suresh Kumar on 13/07/25.
//

import Foundation
import Combine

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

enum APIError: Error {
    case invalidURL
    case invalidResponse
    case statusCode(Int)
    case decodingError(Error)
    case unknown(Error)
    case noResults
    case imageProcessingFailed
    
    var message: String {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response"
        case .statusCode(let code):
            return "Status code: \(code)"
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        case .unknown(_):
            return "tinny hiccup"
        case .noResults:
            return "result not found."
        case .imageProcessingFailed:
            return "image processing Falied"
        }
    }
}

protocol Endpoint {
    var baseURL: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var queryItems: [URLQueryItem]? { get }
    var body: Data? { get }
}

extension Endpoint {
    var baseURL: String {
        return "https://api.github.com"
    }
    
    var headers: [String: String]? {
        var headers = [
            "User-Agent": "GitSearch",
            "Accept": "application/vnd.github.v3+json"
        ]
        headers["Authorization"] = ""
        return headers
    }
    
    var body: Data? {
        return nil
    }
        
    func makeRequest() throws -> URLRequest {
        guard var urlComponents = URLComponents(string: baseURL) else {
            throw APIError.invalidURL
        }
        
        urlComponents.path = path
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.httpBody = body
        headers?.forEach { request.addValue($1, forHTTPHeaderField: $0) }
        
        return request
    }
}

enum GitHubEndpoint: Endpoint {
    case searchUser(query: String, page: Int, perPage: Int)
    case getUserRepos(username: String, page: Int, perPage: Int)
    
    var path: String {
        switch self {
        case .searchUser:
            return "/search/users"
        case .getUserRepos(let username, _, _):
            return "/users/\(username)/repos"
        }
    }
    
    var method: HTTPMethod {
        return .get
    }
    
    var queryItems: [URLQueryItem]? {
        switch self {
        case .searchUser(let query, let page, let perPage):
            return [
                URLQueryItem(name: "q", value: query),
                URLQueryItem(name: "page", value: "\(page)"),
                URLQueryItem(name: "per_page", value: "\(perPage)")
            ]
        case .getUserRepos(_, let page, let perPage):
            return [
                URLQueryItem(name: "page", value: "\(page)"),
                URLQueryItem(name: "per_page", value: "\(perPage)")
            ]
        }
    }
}

// MARK: - Network Service Protocol
protocol NetworkServiceProtocol {
    func request<T: Decodable>(_ endpoint: Endpoint) -> AnyPublisher<T, APIError>
}

final class NetworkService: NetworkServiceProtocol {
    static let shared = NetworkService()
    private let urlSession: URLSession
    
    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }
    
    func request<T: Decodable>(_ endpoint: Endpoint) -> AnyPublisher<T, APIError> {
        do {
            let request = try endpoint.makeRequest()
            
            return urlSession.dataTaskPublisher(for: request)
                .tryMap { data, response in
                    guard let httpResponse = response as? HTTPURLResponse else {
                        throw APIError.invalidResponse
                    }
                    
                    guard 200..<300 ~= httpResponse.statusCode else {
                        throw APIError.statusCode(httpResponse.statusCode)
                    }
                    
                    return data
                }
                .decode(type: T.self, decoder: JSONDecoder())
                .mapError { error in
                    if let apiError = error as? APIError {
                        return apiError
                    } else {
                        return APIError.decodingError(error)
                    }
                }
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
    }
}


