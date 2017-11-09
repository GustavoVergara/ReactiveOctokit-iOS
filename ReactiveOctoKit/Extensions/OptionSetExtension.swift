//
//  OptionSetExtension.swift
//  ReactiveOctoKit
//
//  Created by Gustavo Vergara Garcia on 09/11/17.
//  Copyright © 2017 Gustavo Vergara Garcia. All rights reserved.
//

import Foundation

extension OptionSet {
    
    mutating func `if`(_ bool: Bool, use member: Self.Element) {
        if bool {
            self.insert(member)
        } else {
            self.remove(member)
        }
    }
    
}
