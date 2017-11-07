//
//  LoadingViewController.swift
//  myfreecommApplication
//
//  Created by Gustavo Vergara Garcia on 05/11/17.
//  Copyright © 2017 Gustavo Vergara Garcia. All rights reserved.
//

import UIKit
import ReactiveKit

class LoadingViewController: UIViewController {

    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    lazy var text = Property<String>(self.descriptionLabel?.text ?? "")
    
    lazy var isLoading = Property<Bool>(self.activityIndicator?.isAnimating ?? false)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.text.bind(to: self.descriptionLabel.reactive.text)
        self.isLoading.bind(to: self.activityIndicator.reactive.isAnimating)
    }
    
}
