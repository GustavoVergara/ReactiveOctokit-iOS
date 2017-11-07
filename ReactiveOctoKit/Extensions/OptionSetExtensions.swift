//
//  OptionSetExtensions.swift
//  ReactiveOctoKit
//
//  Created by Gustavo Vergara Garcia on 05/11/17.
//  Copyright © 2017 Gustavo Vergara Garcia. All rights reserved.
//

import Foundation

func +<T: OptionSet>(lhs: T, rhs: T) -> T {
    return lhs.union(rhs)
}

func -<T: OptionSet>(lhs: T, rhs: T) -> T {
    return lhs.subtracting(rhs)
}

func +=<T: OptionSet>(lhs: inout T, rhs: T) {
    lhs.formUnion(rhs)
}

func -=<T: OptionSet>(lhs: inout T, rhs: T) {
    lhs.subtract(rhs)
}
