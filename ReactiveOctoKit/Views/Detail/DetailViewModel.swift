//
//  DetailViewModel.swift
//  ReactiveOctoKit
//
//  Created by Gustavo Vergara Garcia on 04/11/17.
//  Copyright © 2017 Gustavo Vergara Garcia. All rights reserved.
//

import Foundation
import Moya
import Bond
import ReactiveKit

class DetailViewModel {
    
    private let bag = DisposeBag()
    
    // MARK: Observables
    
    let repository = Observable<Repository?>(nil)
            
    let pullRequests = MutableObservableArray<PullRequest>()
    
    let state = Observable<State>([.noRepo, .empty])
    
    // MARK: Provider
    
    private let gitHubAPI = MoyaProvider<GitHub>(callbackQueue: .main, plugins: [NetworkActivityPlugin.default])
    
    // MARK: Page Control
    
    private var shouldGetMorePages = true
    private var currentPage: Int = 0
    
    // MARK: Init
    
    init() {
        self.repository.observeNext { repository in
            if repository == nil {
                self.state.value.insert(.noRepo)
            } else {
                self.state.value.remove(.noRepo)
            }
        }.dispose(in: self.bag)
        
        self.pullRequests.observeNext { pullRequests in
            if self.pullRequests.count == 0 {
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
        
        self.getPullRequests(at: self.currentPage + 1)
    }
    
    // MARK: Private
    
    private func getPullRequests(at page: Int) {
        guard let repository = self.repository.value else { return }
        self.state.value.insert(.gettingNewPage)
        self.gitHubAPI.request(.pullRequests(repository: repository, page: page, pageSize: 100)) { result in
            self.state.value.remove(.gettingNewPage)
            do {
                let response = try result.dematerialize()
                
                let pullRequests: [PullRequest]
                if #available(iOS 10.0, *) {
                    pullRequests = try response.map([PullRequest].self, using: JSONDecoder(dateDecodingStrategy: .iso8601))
                } else {
                    pullRequests = try response.map([PullRequest].self, using: JSONDecoder(dateDecodingStrategy: .formatted(.iso8601)))
                }
                
                self.currentPage = page
                
                if pullRequests.count < 100 {
                    self.state.value.insert(.loadedAllPages)
                }
                
                self.pullRequests.append(contentsOf: pullRequests)
                
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
        static let noRepo = State(rawValue: 1 << 2)
        static let loadedAllPages = State(rawValue: 1 << 3)
    }
    
}
