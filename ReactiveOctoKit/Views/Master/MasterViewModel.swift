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
import ReactiveSwift
import ReactiveCocoa

class MasterViewModel {
    
    private let bag = CompositeDisposable()

    // MARK: Observables
    
    let repositories = MutableProperty<[Repository]>([])
    //MutableObservableArray<Repository>()
    
    let state = MutableProperty<State>([.empty])
//        Observable<State>([.empty])
    
    // MARK: Provider
    
    private let gitHubAPI = MoyaProvider<GitHub>(callbackQueue: .main, plugins: [NetworkActivityPlugin.default])
    
    // MARK: Page Control
    
    private var currentPage: Int = 0
    
    // MARK: Init
    
    init() {
        self.repositories.signal.observeValues { self.state.value.if($0.isEmpty, use: .empty) }?.add(to: self.bag)
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
        self.gitHubAPI.reactive
            .request(.searchRepository(language: .java, page: page, pageSize: 100))
            .map(RepositorySearchResult.self, using: JSONDecoder(dateDecodingStrategy: .iso8601))
            .start { signal in
                self.state.value.remove(.gettingNewPage)
                guard case let .value(searchResult) = signal.event else { return }

                self.currentPage = page
                
                self.state.value.if(self.repositories.value.count >= searchResult.totalCount, use: .loadedAllPages)
                
                self.repositories.value.append(contentsOf: searchResult.items)
            }
            .add(to: self.bag)
    }

    // MARK: -
    
    struct State: OptionSet {
        let rawValue: Int
        
        static let gettingNewPage = State(rawValue: 1 << 0)
        static let empty = State(rawValue: 1 << 1)
        static let loadedAllPages = State(rawValue: 1 << 2)
    }
    
}
