//
//  RepositorySearchResult.swift
//  myfreecommApplication
//
//  Created by Gustavo Vergara Garcia on 03/11/17.
//  Copyright © 2017 Gustavo Vergara Garcia. All rights reserved.
//

import Foundation

struct RepositorySearchResult: Codable {
    var totalCount: Int
    var isIncomplete: Bool
    var items: [Repository]
    
    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case isIncomplete = "incomplete_results"
        case items = "items"
    }
    
}
