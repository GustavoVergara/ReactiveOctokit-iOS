//
//  MasterViewController.swift
//  ReactiveOctoKit
//
//  Created by Gustavo Vergara Garcia on 03/11/17.
//  Copyright © 2017 Gustavo Vergara Garcia. All rights reserved.
//

import UIKit
import Bond
import ReactiveKit
import AlamofireImage

class MasterViewController: UIViewController, UITableViewDelegate {

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
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.splitViewController?.isCollapsed == true {
            self.tableView.deselectAll(animated: true)
        }
    }
    
    func makeBindings() {
        self.viewModel.state.map({ $0.contains(.gettingNewPage) }).bind(to: self.loadingViewController.isLoading)
        self.viewModel.state.map({ !$0.contains([.gettingNewPage, .empty]) }).bind(to: self.loadingContainer.reactive.isHidden)
        
        self.viewModel.repositories.bind(to: self.tableView, animated: false, createCell: self.createCell(with:at:for:))
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case let navigationController as UINavigationController:
            switch navigationController.viewControllers.first! {
            case let detailViewController as DetailViewController:
                guard let selectedIndexPath = tableView.indexPathForSelectedRow else { return }

                detailViewController.viewModel.repository.value = self.viewModel.repositories[selectedIndexPath.row]

            default: break
            }
            
        default: break
        }
    }

    // MARK: - Table View
    
    func createCell(with repositories: ObservableArray<Repository>, at indexPath: IndexPath, for tableView: UITableView) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel?.text = repositories[indexPath.row].name
        cell.detailTextLabel?.text = repositories[indexPath.row].description
        
        if let avatarURL = repositories[indexPath.row].owner.avatarURL {
            let imageFilter = AspectScaledToFillSizeWithRoundedCornersFilter(size: CGSize(width: 44, height: 44), radius: 22)
            let placeholder = UIImage(named: "github-octocat")?.af_imageAspectScaled(toFit: CGSize(width: 44, height: 44))
            cell.imageView?.af_setImage(withURL: avatarURL, placeholderImage: placeholder, filter: imageFilter)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (Double(indexPath.row) / Double(self.viewModel.repositories.endIndex)) > 0.7 {
            self.viewModel.getNextPage()
        }
    }

}
