//
//  MasterViewModel.swift
//  ReactiveOctoKit
//
//  Created by Gustavo Vergara Garcia on 03/11/17.
//  Copyright © 2017 Gustavo Vergara Garcia. All rights reserved.
//

import Foundation
import UIKit
import Moya
import Bond
import ReactiveKit

class MasterViewModel {
    
    let bag = DisposeBag()
    
    // MARK: Observables
    
    let repositories = MutableObservableArray<Repository>()
    
    let state = Observable<State>([.empty])
    
    // MARK: Provider
    
    private let gitHubAPI = MoyaProvider<GitHub>(callbackQueue: .main, plugins: [NetworkActivityPlugin.default])
    
    // MARK: Page Control
    
    private var currentPage: Int = 0
    
    // MARL: Init
    
    init() {
        self.repositories.observeNext { repositories in
            if self.repositories.count == 0 {
                self.state.value.insert(.empty)
            } else {
                self.state.value.remove(.empty)
            }
        }.dispose(in: self.bag)
    }
    
    // MARK: - Methods
    
    // MARK: Public
    
    func getNextPage() {
        guard (self.state.value.contains(.gettingNewPage) || self.state.value.contains(.loadedAllPages)) == false else { return }
        
        self.getRepos(at: self.currentPage + 1)
    }
    
    // MARK: Private
    
    private func getRepos(at page: Int) {
        self.state.value.insert(.gettingNewPage)
        self.gitHubAPI.request(.searchRepository(language: .java, page: page, pageSize: 100)) { result in
            self.state.value.remove(.gettingNewPage)
            do {
                let response = try result.dematerialize()
                
                let searchResult: RepositorySearchResult
                if #available(iOS 10.0, *) {
                    searchResult = try response.map(RepositorySearchResult.self, using: JSONDecoder(dateDecodingStrategy: .iso8601))
                } else {
                    searchResult = try response.map(RepositorySearchResult.self, using: JSONDecoder(dateDecodingStrategy: .formatted(.iso8601)))
                }
                
                self.currentPage = page
                if self.repositories.count >= searchResult.totalCount {
                    self.state.value.insert(.loadedAllPages)
                } else {
                    self.state.value.remove(.loadedAllPages)
                }
                
                self.repositories.append(contentsOf: searchResult.items)
            } catch {
                print(error)
            }
            
        }
    }

    // MARK: -
    
    struct State: OptionSet {
        let rawValue: Int
        
        static let gettingNewPage = State(rawValue: 1 << 0)
        static let empty = State(rawValue: 1 << 1)
        static let loadedAllPages = State(rawValue: 1 << 2)
    }
    
}
