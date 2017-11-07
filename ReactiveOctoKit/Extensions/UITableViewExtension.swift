//
//  UITableViewExtension.swift
//  ReactiveOctoKit
//
//  Created by Gustavo Vergara Garcia on 05/11/17.
//  Copyright © 2017 Gustavo Vergara Garcia. All rights reserved.
//

import Foundation
import UIKit

extension UITableView {
    
    func deselectAll(animated: Bool) {
        guard let selectedIndexPaths = self.indexPathsForSelectedRows else { return }
        
        for selectedIndexPath in selectedIndexPaths {
            self.deselectRow(at: selectedIndexPath, animated: animated)
        }
    }
    
}
