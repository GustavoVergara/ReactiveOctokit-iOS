//
//  DetailViewController.swift
//  ReactiveOctoKit
//
//  Created by Gustavo Vergara Garcia on 03/11/17.
//  Copyright © 2017 Gustavo Vergara Garcia. All rights reserved.
//

import UIKit
import ReactiveKit
import Bond
import AlamofireImage

class DetailViewController: UIViewController, UITableViewDelegate {

    let viewModel = DetailViewModel()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingContainer: UIView!
    @IBOutlet weak var starsLabel: UILabel!
    @IBOutlet weak var forksLabel: UILabel!
    @IBOutlet weak var watchersLabel: UILabel!
    
    lazy var loadingViewController: LoadingViewController! = {
        return self.childViewControllers.reduce(nil, { return $0 ?? $1 as? LoadingViewController })
    }()
    
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
        self.viewModel.state.map({ $0.contains(.empty) ? nil : UIView() }).observeNext(with: { self.tableView.tableFooterView = $0 }).dispose(in: self.bag)
        
        self.viewModel.state.map({ !($0.contains(.noRepo) || $0.contains([.gettingNewPage, .empty])) }).bind(to: self.loadingContainer.reactive.isHidden)
        
        if let loadingViewController = self.loadingViewController {
            self.viewModel.state.map({ $0.contains(.noRepo) ? "Selecione um repositorio" : "Carregando pull requests" }).bind(to: loadingViewController.text)
            self.viewModel.state.map({ $0.contains(.gettingNewPage) }).bind(to: loadingViewController.isLoading)
        }
        
        self.viewModel.repository.flatMap({ $0?.name ?? $0?.fullName }).bind(to: self.navigationItem.reactive.title)
        self.viewModel.repository.map({ $0?.forksCount ?? 0 }).map({"\($0)"}).bind(to: self.forksLabel.reactive.text)
        self.viewModel.repository.map({ $0?.stargazersCount ?? 0 }).map({"\($0)"}).bind(to: self.starsLabel.reactive.text)
        self.viewModel.repository.map({ $0?.watchersCount ?? 0 }).map({"\($0)"}).bind(to: self.watchersLabel.reactive.text)

        self.viewModel.pullRequests.bind(to: self.tableView, animated: false, createCell: self.createCell(with:at:for:))
    }
    
    // MARK: - UITableView
    
    func createCell(with pullRequests: ObservableArray<PullRequest>, at indexPath: IndexPath, for tableView: UITableView) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel?.text = pullRequests[indexPath.row].title
        cell.detailTextLabel?.text = pullRequests[indexPath.row].body
        
        if let avatarURL = pullRequests[indexPath.row].user?.avatarURL {
            let imageFilter = AspectScaledToFillSizeWithRoundedCornersFilter(size: CGSize(width: 44, height: 44), radius: 22)
            let placeholder = UIImage(named: "github-octocat")?.af_imageAspectScaled(toFit: CGSize(width: 44, height: 44))
            cell.imageView?.af_setImage(withURL: avatarURL, placeholderImage: placeholder, filter: imageFilter)
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (Double(indexPath.row) / Double(self.viewModel.pullRequests.endIndex)) > 0.7 {
            self.viewModel.getNextPage()
        }
    }

}

