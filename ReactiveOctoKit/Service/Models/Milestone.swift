//
//  Milestone.swift
//  myfreecommApplication
//
//  Created by Gustavo Vergara Garcia on 03/11/17.
//  Copyright © 2017 Gustavo Vergara Garcia. All rights reserved.
//

import Foundation

struct Milestone: Codable {
    var url: URL?
    var htmlURL: URL?
    var labelsURL: URL?
    var id: Int
    var number: Int?
    var state: State?
    var title: String?
    var milestoneDescription: String?
    var creator: User?
    var openIssues: Int?
    var closedIssues: Int?
    var createdAt: Date?
    var updatedAt: Date?
    var closedAt: Date?
    var dueOn: Date?

}
