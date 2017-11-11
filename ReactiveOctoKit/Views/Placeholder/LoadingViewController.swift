//
//  LoadingViewController.swift
//  ReactiveOctoKit
//
//  Created by Gustavo Vergara Garcia on 05/11/17.
//  Copyright © 2017 Gustavo Vergara Garcia. All rights reserved.
//

import UIKit
import RxSwift

class LoadingViewController: UIViewController {

    @IBOutlet fileprivate weak var descriptionLabel: UILabel!
    @IBOutlet fileprivate weak var activityIndicator: UIActivityIndicatorView!
    
    private let bag = DisposeBag()

    lazy var text = Variable<String>(self.descriptionLabel?.text ?? "")
    
    lazy var isLoading = Variable<Bool>(self.activityIndicator?.isAnimating ?? false)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.text.asObservable().bind(to: self.descriptionLabel.rx.text).disposed(by: self.bag)
        self.isLoading.asObservable().bind(to: self.activityIndicator.rx.isAnimating).disposed(by: self.bag)
    }
    
}
