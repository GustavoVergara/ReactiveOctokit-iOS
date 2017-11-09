//
//  DetailViewController.swift
//  ReactiveOctoKit
//
//  Created by Gustavo Vergara Garcia on 03/11/17.
//  Copyright © 2017 Gustavo Vergara Garcia. All rights reserved.
//

import UIKit
import AlamofireImage
import ReactiveSwift
import ReactiveCocoa

class DetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let viewModel = DetailViewModel()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingContainer: UIView!
    @IBOutlet weak var starsLabel: UILabel!
    @IBOutlet weak var forksLabel: UILabel!
    @IBOutlet weak var watchersLabel: UILabel!
    
    lazy var loadingViewController: LoadingViewController! = {
        return self.childViewControllers.reduce(nil, { return $0 ?? $1 as? LoadingViewController })
    }()
    
    private let bag = CompositeDisposable()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
        self.navigationItem.leftItemsSupplementBackButton = true
        
        self.makeBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.viewModel.getNextPage()
    }
    
    func makeBindings() {
        // Removes additional lines on the tableView when the tableView is not empty
        self.bag += self.viewModel.state.signal.map({ $0.contains(.empty) ? nil : UIView() }).observeValues({ self.tableView.tableFooterView = $0 })
        
        self.bag += self.loadingContainer.reactive.isHidden <~ self.viewModel.state.map({ !($0.contains(.noRepo) || $0.contains([.gettingNewPage, .empty])) })
        
        if let loadingViewController = self.loadingViewController {
            self.bag += loadingViewController.text <~ self.viewModel.state.map({ $0.contains(.noRepo) ? "Selecione um repositorio" : "Carregando pull requests" })
            self.bag += loadingViewController.isLoading <~ self.viewModel.state.map({ $0.contains(.gettingNewPage) })
        }
        
        self.bag += self.navigationItem.reactive.title <~ self.viewModel.repository.signal.map({ $0?.name ?? $0?.fullName }).skipNil()
        
        self.bag += self.forksLabel.reactive.text <~ self.viewModel.repository.map({ $0?.forksCount ?? 0 }).map({"\($0)"})
        self.bag += self.starsLabel.reactive.text <~ self.viewModel.repository.map({ $0?.stargazersCount ?? 0 }).map({"\($0)"})
        self.bag += self.watchersLabel.reactive.text <~ self.viewModel.repository.map({ $0?.watchersCount ?? 0 }).map({"\($0)"})

        self.bag += self.tableView.reactive.reloadData <~ self.viewModel.pullRequests.signal.map { _ in () }
    }
    
    // MARK: - UITableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.pullRequests.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel?.text = self.viewModel.pullRequests.value[indexPath.row].title
        cell.detailTextLabel?.text = self.viewModel.pullRequests.value[indexPath.row].body
        
        if let avatarURL = self.viewModel.pullRequests.value[indexPath.row].user?.avatarURL {
            let imageFilter = AspectScaledToFillSizeWithRoundedCornersFilter(size: CGSize(width: 44, height: 44), radius: 22)
            let placeholder = UIImage(named: "github-octocat")?.af_imageAspectScaled(toFit: CGSize(width: 44, height: 44))
            cell.imageView?.af_setImage(withURL: avatarURL, placeholderImage: placeholder, filter: imageFilter)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (Double(indexPath.row) / Double(self.viewModel.pullRequests.value.endIndex)) > 0.7 {
            self.viewModel.getNextPage()
        }
    }

}

