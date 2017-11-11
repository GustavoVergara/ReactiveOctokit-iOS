//
//  DetailViewModel.swift
//  ReactiveOctoKit
//
//  Created by Gustavo Vergara Garcia on 04/11/17.
//  Copyright © 2017 Gustavo Vergara Garcia. All rights reserved.
//

import Foundation
import Moya
import RxSwift

class DetailViewModel {
    
    private let bag = DisposeBag()
    
    // MARK: Observables
    
    let repository = Variable<Repository?>(nil)
    
    let pullRequests = Variable<[PullRequest]>([])
    
    let state = Variable<State>([.noRepo, .empty])
    
    // MARK: Provider
    
    private let gitHubAPI = MoyaProvider<GitHub>(callbackQueue: .main, plugins: [NetworkActivityPlugin.default])
    
    // MARK: Page Control
    
    private var shouldGetMorePages = true
    private var currentPage: Int = 0
    
    // MARK: Init
    
    init() {
        self.repository.asObservable()
            .subscribe(onNext: { [weak self] in self?.state.value.if($0 == nil, use: .noRepo) })
            .disposed(by: self.bag)
        self.repository.asObservable()
            .filter({ $0 != nil })
            .subscribe(onNext: { [weak self] _ in self?.getNextPage()  })
            .disposed(by: self.bag)
        self.pullRequests.asObservable()
            .subscribe(onNext: { [weak self] in self?.state.value.if($0.isEmpty, use: .empty) })
            .disposed(by: self.bag)
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
        
        self.gitHubAPI.rx
            .request(.pullRequests(repository: repository, page: page, pageSize: 100))
            .map([PullRequest].self, using: JSONDecoder(dateDecodingStrategy: .iso8601))
            .subscribe { event in
                self.state.value.remove(.gettingNewPage)
                guard case let .success(pullRequests) = event else { return }

                self.currentPage = page
                
                self.state.value.if(pullRequests.count < 100, use: .loadedAllPages)
                
                self.pullRequests.value.append(contentsOf: pullRequests)
            }
            .disposed(by: self.bag)
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
