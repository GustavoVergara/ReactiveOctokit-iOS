//
//  MasterViewController.swift
//  ReactiveOctoKit
//
//  Created by Gustavo Vergara Garcia on 03/11/17.
//  Copyright © 2017 Gustavo Vergara Garcia. All rights reserved.
//

import UIKit
import AlamofireImage
import ReactiveSwift
import ReactiveCocoa

class MasterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingContainer: UIView!
    
    lazy var loadingViewController: LoadingViewController! = {
        return self.childViewControllers.reduce(nil, { return $0 ?? $1 as? LoadingViewController })
    }()
    
    let viewModel = MasterViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        
        self.loadingViewController.text.value = "Carregando repos.."
        
        self.makeBindings()
        
        self.viewModel.getNextPage()
        
//        self.reactive.signal(for: #selector(UITableViewDataSource.tableView(_:numberOfRowsInSection:))).observeValues { stuff in
//            print(stuff)
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.splitViewController?.isCollapsed == true {
            self.tableView.deselectAll(animated: true)
        }
    }
    
    func makeBindings() {
        self.loadingViewController.isLoading <~ self.viewModel.state.map({ $0.contains(.gettingNewPage) })
        self.loadingContainer.reactive.isHidden <~ self.viewModel.state.map({ !$0.contains([.gettingNewPage, .empty]) })
        
        self.tableView.reactive.reloadData <~ self.viewModel.repositories.signal.map { _ in () }
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case let navigationController as UINavigationController:
            switch navigationController.viewControllers.first! {
            case let detailViewController as DetailViewController:
                guard let selectedIndexPath = tableView.indexPathForSelectedRow else { return }

                detailViewController.viewModel.repository.value = self.viewModel.repositories.value[selectedIndexPath.row]

            default: break
            }
            
        default: break
        }
    }

    // MARK: - Table View
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.repositories.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel?.text = self.viewModel.repositories.value[indexPath.row].name
        cell.detailTextLabel?.text = self.viewModel.repositories.value[indexPath.row].description
        
        if let avatarURL = self.viewModel.repositories.value[indexPath.row].owner.avatarURL {
            let imageFilter = AspectScaledToFillSizeWithRoundedCornersFilter(size: CGSize(width: 44, height: 44), radius: 22)
            let placeholder = UIImage(named: "github-octocat")?.af_imageAspectScaled(toFit: CGSize(width: 44, height: 44))
            cell.imageView?.af_setImage(withURL: avatarURL, placeholderImage: placeholder, filter: imageFilter)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (Double(indexPath.row) / Double(self.viewModel.repositories.value.endIndex)) > 0.7 {
            self.viewModel.getNextPage()
        }
    }

}
