//
//  ReactiveKitExtensions.swift
//  myfreecommApplication
//
//  Created by Gustavo Vergara Garcia on 03/11/17.
//  Copyright © 2017 Gustavo Vergara Garcia. All rights reserved.
//

import Foundation
import Bond

extension MutableObservableArray {
    
    public func append(contentsOf newElements: [Item]) {
        self.insert(contentsOf: newElements, at: self.count)
    }
    
}
