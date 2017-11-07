//
//  GitHubProvider.swift
//  ReactiveOctoKit
//
//  Created by Gustavo Vergara Garcia on 03/11/17.
//  Copyright © 2017 Gustavo Vergara Garcia. All rights reserved.
//

import Foundation
import Moya
import Alamofire

enum SortField: String {
    case stars
    case forks
    case updated
}

enum SortOrder: String {
    case asc
    case desc
}

enum ProgrammingLanguage: String {
    case java = "Java"
    case swift = "Swift"
}

enum GitHub: TargetType {
    case searchRepository(language: ProgrammingLanguage, page: Int, pageSize: Int)
    case pullRequests(repository: Repository, page: Int, pageSize: Int)
    
    /// The target's base `URL`.
    var baseURL: URL {
        return URL(string: "http://api.github.com")!
    }
    
    /// The path to be appended to `baseURL` to form the full `URL`.
    var path: String {
        switch self {
        case .searchRepository: return "/search/repositories"
        case let .pullRequests(repository, _, _): return "/repos/\(repository.owner.login)/\(repository.name)/pulls"
        }
    }
    
    /// The HTTP method used in the request.
    var method: Moya.Method {
        switch self {
        case .searchRepository: return .get
        case .pullRequests: return .get
        }
    }
    
    /// Provides stub data for use in testing.
    var sampleData: Data {
        switch self {
        case .searchRepository: return SampleData.searchRepositoryResponseBody
        case .pullRequests: return SampleData.pullRequestsResponseBody
        }
    }
    
    /// The type of HTTP task to be performed.
    var task: Task {
        switch self {
        case let .searchRepository(language, page, pageSize):
            return .requestParameters(parameters: ["q":"language:\(language)", "page": page, "per_page": pageSize], encoding: URLEncoding())
        case let .pullRequests(_, page, pageSize):
            return .requestParameters(parameters: ["page": page, "per_page": pageSize], encoding: URLEncoding())
        }
    }
    
    /// The headers to be used in the request.
    var headers: [String: String]? {
        switch self {
        case .searchRepository: return nil
        case .pullRequests: return nil
        }
    }
    
}
