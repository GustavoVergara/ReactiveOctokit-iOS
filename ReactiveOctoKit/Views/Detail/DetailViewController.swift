//
//  DetailViewController.swift
//  ReactiveOctoKit
//
//  Created by Gustavo Vergara Garcia on 03/11/17.
//  Copyright © 2017 Gustavo Vergara Garcia. All rights reserved.
//

import UIKit
import AlamofireImage
import RxSwift
import RxCocoa
import RxOptional

class DetailViewController: UIViewController {

    let viewModel = DetailViewModel()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingContainer: UIView!
    @IBOutlet weak var starsLabel: UILabel!
    @IBOutlet weak var forksLabel: UILabel!
    @IBOutlet weak var watchersLabel: UILabel!
    
    lazy var loadingViewController: LoadingViewController! = {
        return self.childViewControllers.reduce(nil, { return $0 ?? $1 as? LoadingViewController })
    }()
    
    private let bag = DisposeBag()
    
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
        self.viewModel.state.asObservable()
            .map({ $0.contains(.empty) ? nil : UIView() })
            .subscribe(onNext: { self.tableView.tableFooterView = $0 })
            .disposed(by: self.bag)
        
        self.viewModel.state.asObservable()
            .map({ !($0.contains(.noRepo) || $0.contains([.gettingNewPage, .empty])) })
            .bind(to: self.loadingContainer.rx.isHidden)
            .disposed(by: self.bag)
        
        if let loadingViewController = self.loadingViewController {
            self.viewModel.state.asObservable()
                .map({ $0.contains(.noRepo) ? "Selecione um repositorio" : "Carregando pull requests" })
                .bind(to: loadingViewController.text)
                .disposed(by: self.bag)
            
            self.viewModel.state.asObservable()
                .map({ $0.contains(.gettingNewPage) })
                .bind(to: loadingViewController.isLoading)
                .disposed(by: self.bag)
        }
        
        self.viewModel.repository.asObservable()
            .map({ $0?.name ?? $0?.fullName })
            .filterNil()
            .bind(to: self.navigationItem.rx.title)
            .disposed(by: self.bag)
        
        self.viewModel.repository.asObservable().map({ $0?.forksCount ?? 0 }).map({"\($0)"}).bind(to: self.forksLabel.rx.text).disposed(by: self.bag)
        self.viewModel.repository.asObservable().map({ $0?.stargazersCount ?? 0 }).map({"\($0)"}).bind(to: self.starsLabel.rx.text).disposed(by: self.bag)
        self.viewModel.repository.asObservable().map({ $0?.watchersCount ?? 0 }).map({"\($0)"}).bind(to: self.watchersLabel.rx.text).disposed(by: self.bag)

        self.viewModel.pullRequests.asObservable()
            .bind(to: self.tableView.rx.items(cellIdentifier: "Cell"))
            { (row, pullRequest, cell) in
                cell.textLabel?.text = pullRequest.title
                cell.detailTextLabel?.text = pullRequest.body
                
                if let avatarURL = pullRequest.user?.avatarURL {
                    let imageFilter = AspectScaledToFillSizeWithRoundedCornersFilter(size: CGSize(width: 44, height: 44), radius: 22)
                    let placeholder = UIImage(named: "github-octocat")?.af_imageAspectScaled(toFit: CGSize(width: 44, height: 44))
                    cell.imageView?.af_setImage(withURL: avatarURL, placeholderImage: placeholder, filter: imageFilter)
                }
            }
            .disposed(by: self.bag)
        
        self.tableView.rx.willDisplayCell.asObservable()
            .map { [unowned self] in Double($1.row) / Double(self.viewModel.pullRequests.value.endIndex) }
            .filter({ $0 > 0.7 })
            .map({ _ in () })
            .bind(onNext: self.viewModel.getNextPage)
            .disposed(by: self.bag)
    }
    
    // MARK: - UITableView
    
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return self.viewModel.pullRequests.value.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
//
//        cell.textLabel?.text = self.viewModel.pullRequests.value[indexPath.row].title
//        cell.detailTextLabel?.text = self.viewModel.pullRequests.value[indexPath.row].body
//
//        if let avatarURL = self.viewModel.pullRequests.value[indexPath.row].user?.avatarURL {
//            let imageFilter = AspectScaledToFillSizeWithRoundedCornersFilter(size: CGSize(width: 44, height: 44), radius: 22)
//            let placeholder = UIImage(named: "github-octocat")?.af_imageAspectScaled(toFit: CGSize(width: 44, height: 44))
//            cell.imageView?.af_setImage(withURL: avatarURL, placeholderImage: placeholder, filter: imageFilter)
//        }
//
//        return cell
//    }
    
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        if (Double(indexPath.row) / Double(self.viewModel.pullRequests.value.endIndex)) > 0.7 {
//            self.viewModel.getNextPage()
//        }
//    }

}

