//
//  ReactiveSwiftExtensions.swift
//  ReactiveOctoKit
//
//  Created by Gustavo Vergara Garcia on 09/11/17.
//  Copyright © 2017 Gustavo Vergara Garcia. All rights reserved.
//

import Foundation
import ReactiveSwift

extension Disposable {
    
    func add(to compositeDisposable: CompositeDisposable) {
        compositeDisposable.add(self)
    }
    
}
