//
//  DetailViewModel.swift
//  ReactiveOctoKit
//
//  Created by Gustavo Vergara Garcia on 04/11/17.
//  Copyright © 2017 Gustavo Vergara Garcia. All rights reserved.
//

import Foundation
import Moya
import ReactiveSwift

class DetailViewModel {
    
    private let bag = CompositeDisposable()
    
    // MARK: Observables
    
    let repository = MutableProperty<Repository?>(nil)
            
    let pullRequests = MutableProperty<[PullRequest]>([])
    
    let state = MutableProperty<State>([.noRepo, .empty])
    
    // MARK: Provider
    
    private let gitHubAPI = MoyaProvider<GitHub>(callbackQueue: .main, plugins: [NetworkActivityPlugin.default])
    
    // MARK: Page Control
    
    private var shouldGetMorePages = true
    private var currentPage: Int = 0
    
    // MARK: Init
    
    init() {
        self.repository.signal.observeValues { [weak self] in self?.state.value.if($0 == nil, use: .noRepo) }?.add(to: self.bag)
        self.repository.signal.skipNil().observeValues { [weak self] _ in self?.getNextPage() }
        self.pullRequests.signal.observeValues { [weak self] in self?.state.value.if($0.isEmpty, use: .empty) }?.add(to: self.bag)
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
        
        self.gitHubAPI.reactive
            .request(.pullRequests(repository: repository, page: page, pageSize: 100))
            .map([PullRequest].self, using: JSONDecoder(dateDecodingStrategy: .iso8601))
            .start { signal in
                self.state.value.remove(.gettingNewPage)
                guard case let .value(pullRequests) = signal.event else { return }

                self.currentPage = page
                
                self.state.value.if(pullRequests.count < 100, use: .loadedAllPages)
                
                self.pullRequests.value.append(contentsOf: pullRequests)
            }
            .add(to: self.bag)
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
