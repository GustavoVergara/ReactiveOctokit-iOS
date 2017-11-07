//
//  Label.swift
//  ReactiveOctoKit
//
//  Created by Gustavo Vergara Garcia on 03/11/17.
//  Copyright © 2017 Gustavo Vergara Garcia. All rights reserved.
//

import Foundation
import UIKit

struct Label: Codable {
    public var url: URL?
    public var name: String?
    public var color: UIColor?
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.url = try container.decode(URL.self, forKey: .url)
        self.name = try container.decode(String.self, forKey: .name)
        self.color = nil // TODO: Decode color
    }
    
    public func encode(to encoder: Encoder) throws {
        throw NSError(domain: "", code: 0, userInfo: nil)
    }

    enum CodingKeys: String, CodingKey {
        case url
        case name
        case color
    }
    
}
