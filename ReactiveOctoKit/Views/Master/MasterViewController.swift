//
//  MasterViewController.swift
//  ReactiveOctoKit
//
//  Created by Gustavo Vergara Garcia on 03/11/17.
//  Copyright © 2017 Gustavo Vergara Garcia. All rights reserved.
//

import UIKit
import AlamofireImage
import RxSwift
import RxCocoa

class MasterViewController: UIViewController, UITableViewDataSource, RxTableViewDataSourceType {
    
    typealias Element = [Repository]
    

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingContainer: UIView!
    
    private let bag = DisposeBag()

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
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.splitViewController?.isCollapsed == true {
            self.tableView.deselectAll(animated: true)
        }
    }
    
    func makeBindings() {
        self.viewModel.state.asObservable()
            .map { $0.contains(.gettingNewPage) }
            .bind(to: self.loadingViewController.isLoading)
            .disposed(by: self.bag)

        self.viewModel.state.asObservable()
            .map { !$0.contains([.gettingNewPage, .empty]) }
            .bind(to: self.loadingContainer.rx.isHidden)
            .disposed(by: self.bag)
        
        
        self.viewModel.repositories.asObservable()
            .bind(to: self.tableView.rx.items(cellIdentifier: "Cell"))
            { (row, repository, cell) in
                cell.textLabel?.text = repository.name
                cell.detailTextLabel?.text = repository.description
                
                if let avatarURL = repository.owner.avatarURL {
                    let imageFilter = AspectScaledToFillSizeWithRoundedCornersFilter(size: CGSize(width: 44, height: 44), radius: 22)
                    let placeholder = UIImage(named: "github-octocat")?.af_imageAspectScaled(toFit: CGSize(width: 44, height: 44))
                    cell.imageView?.af_setImage(withURL: avatarURL, placeholderImage: placeholder, filter: imageFilter)
                }
            }
            .disposed(by: self.bag)
        
        self.tableView.rx.willDisplayCell.asObservable()
            .map { Double($1.row) / Double(self.viewModel.repositories.value.endIndex) }
            .filter({ $0 > 0.7 })
            .subscribe(onNext: { _ in self.viewModel.getNextPage() })
            .disposed(by: self.bag)

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
    
    func tableView(_ tableView: UITableView, observedEvent: Event<[Repository]>) {
//        guard case let .next(repository) = observedEvent else { return }
        
        tableView.reloadData()
    }

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
