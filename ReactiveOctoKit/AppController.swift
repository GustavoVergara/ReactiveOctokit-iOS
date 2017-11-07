//
//  AppController.swift
//  ReactiveOctoKit
//
//  Created by Gustavo Vergara Garcia on 03/11/17.
//  Copyright © 2017 Gustavo Vergara Garcia. All rights reserved.
//

import Foundation
import UIKit

class AppController: UISplitViewControllerDelegate {
    
    static let shared: AppController = AppController()
    
    private init() {}
    
    func didFinishLaunching(withOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        guard let window = AppDelegate.shared.window else {
            return false
        }
        
        if  let splitViewController = window.rootViewController as? UISplitViewController,
            let navigationController = splitViewController.detailViewController as? UINavigationController
        {
            navigationController.topViewController?.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
            splitViewController.delegate = self
        }
        
        return true
    }
    
    // MARK: - Split view
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        guard let secondaryAsNavController = secondaryViewController as? UINavigationController else { return false }
        guard let detailViewController = secondaryAsNavController.topViewController as? DetailViewController else { return false }
        // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
        return detailViewController.viewModel.repository.value == nil
    }
    
}

extension UISplitViewController {
    
    var masterViewController: UIViewController? {
        return self.viewControllers.first
    }
    
    var detailViewController: UIViewController? {
        return (self.viewControllers.count == 2) ? self.viewControllers[1] : nil
    }
    
}
