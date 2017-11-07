//
//  MoyaExtension.swift
//  myfreecommApplication
//
//  Created by Gustavo Vergara Garcia on 03/11/17.
//  Copyright © 2017 Gustavo Vergara Garcia. All rights reserved.
//

import Foundation
import Moya

extension NetworkActivityPlugin {
    static let `default` = NetworkActivityPlugin(networkActivityClosure: { (change, target) in
        UIApplication.shared.isNetworkActivityIndicatorVisible = change == .began
    })
}

extension MoyaProvider {
    
    func inflightRequests(for target: Target) -> [Completion] {
        return self.inflightRequests[self.endpoint(target)] ?? []
    }
    
}
