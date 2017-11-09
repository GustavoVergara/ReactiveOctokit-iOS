//
//  LoadingViewController.swift
//  ReactiveOctoKit
//
//  Created by Gustavo Vergara Garcia on 05/11/17.
//  Copyright © 2017 Gustavo Vergara Garcia. All rights reserved.
//

import UIKit
import ReactiveSwift

class LoadingViewController: UIViewController {

    @IBOutlet fileprivate weak var descriptionLabel: UILabel!
    @IBOutlet fileprivate weak var activityIndicator: UIActivityIndicatorView!
    
    lazy var text = MutableProperty<String>(self.descriptionLabel?.text ?? "")
    
    lazy var isLoading = MutableProperty<Bool>(self.activityIndicator?.isAnimating ?? false)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.descriptionLabel.reactive.text <~ self.text
        self.activityIndicator.reactive.isAnimating <~ self.isLoading
    }
    
}
