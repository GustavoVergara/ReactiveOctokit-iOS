//
//  Issue.swift
//  myfreecommApplication
//
//  Created by Gustavo Vergara Garcia on 03/11/17.
//  Copyright © 2017 Gustavo Vergara Garcia. All rights reserved.
//

import Foundation

struct Issue: Codable {
    var id: Int
    var url: URL?
    var repositoryURL: URL?
    var labelsURL: URL?
    var commentsURL: URL?
    var eventsURL: URL?
    var htmlURL: URL?
    var number: Int?
    var state: State?
    var title: String?
    var body: String?
    var user: User?
    var labels: [Label]?
    var assignee: User?
    var milestone: Milestone?
    var locked: Bool?
    var comments: Int?
    var closedAt: Date?
    var createdAt: Date?
    var updatedAt: Date?
    var closedBy: User?
}
