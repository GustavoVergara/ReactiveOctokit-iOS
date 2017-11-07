//
//  Repository.swift
//  myfreecommApplication
//
//  Created by Gustavo Vergara Garcia on 03/11/17.
//  Copyright © 2017 Gustavo Vergara Garcia. All rights reserved.
//

import Foundation

struct Repository: Codable {
    let id: Int
    let owner: User
    var name: String
    var fullName: String?
    var isPrivate: Bool
    var description: String?
    var isFork: Bool?
    var gitURL: URL?
    var sshURL: URL?
    var cloneURL: URL?
    var htmlURL: String?
    var size: Int
    var lastPush: Date?
    var watchersCount: Int?
    var forksCount: Int?
    var stargazersCount: Int?
    
    enum CodingKeys: String, CodingKey {
        case id
        case owner
        case name
        case fullName = "full_name"
        case isPrivate = "private"
        case description
        case isFork = "fork"
        case gitURL = "git_url"
        case sshURL = "ssh_url"
        case cloneURL = "clone_url"
        case htmlURL = "html_url"
        case size
        case lastPush = "pushed_at"
        case watchersCount = "watchers_count"
        case forksCount = "forks_count"
        case stargazersCount = "stargazers_count"
    }
    
}
