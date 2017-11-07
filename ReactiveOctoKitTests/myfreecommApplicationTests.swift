//
//  ReactiveOctoKitTests.swift
//  ReactiveOctoKitTests
//
//  Created by Gustavo Vergara Garcia on 05/11/17.
//  Copyright © 2017 Gustavo Vergara Garcia. All rights reserved.
//

import XCTest
@testable import ReactiveOctoKit
import Moya
import Result

class ReactiveOctoKitTests: XCTestCase {
    
    let gitHubSuccessProvider = MoyaProvider<GitHub>(
        endpointClosure: { target -> Endpoint<GitHub> in
            return Endpoint<GitHub>(mock: target, returning: .networkResponse(200, target.sampleData))
        },
        callbackQueue: DispatchQueue(label: "repocallback", attributes: .concurrent)
    )
    
    override func setUp() {
        super.setUp()
        
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSuccessfulSearch() {
        let group = DispatchGroup()

        group.enter()
        self.gitHubSuccessProvider.request(.searchRepository(language: .java, page: 1, pageSize: 100)) { result in
            do {
                XCTAssertNoThrow(try result.dematerialize(), "Did not receive data")
                let response = try result.dematerialize()
                
                XCTAssertNoThrow(try response.map(RepositorySearchResult.self, using: JSONDecoder(dateDecodingStrategy: .formatted(.iso8601))), "Could not parse response")
                
                let searchResult = try response.map(RepositorySearchResult.self, using: JSONDecoder(dateDecodingStrategy: .formatted(.iso8601)))
                
                XCTAssert(searchResult.items.count > 0, "No repo received")
                
                if searchResult.totalCount <= 100 {
                    XCTAssert(searchResult.items.count >= searchResult.totalCount, "Not enough repo")
                }
                
            } catch {
                XCTAssert(false, String(describing: error))
            }
            group.leave()
        }
        
        group.wait()
        
    }
    
    func testSuccessfulPullRequestsGet() {
        let group = DispatchGroup()
        
        group.enter()
        self.gitHubSuccessProvider.request(.pullRequests(repository: self.getTestRepository(), page: 1, pageSize: 100)) { result in
            do {
                XCTAssertNoThrow(try result.dematerialize(), "Did not receive data")
                let response = try result.dematerialize()
                
                XCTAssertNoThrow(try response.map([PullRequest].self), "Could not parse response")
                
            } catch {
                XCTAssert(false, String(describing: error))
            }
            group.leave()
        }
        
        group.wait()
    }
    
    func getTestRepository() -> Repository {
        let group = DispatchGroup()
        
        var repo: Repository?
        
        group.enter()
        self.gitHubSuccessProvider.request(.searchRepository(language: .java, page: 1, pageSize: 100)) { result in
            let response = try! result.dematerialize()
            let searchResult = try! response.map(RepositorySearchResult.self, using: JSONDecoder(dateDecodingStrategy: .formatted(.iso8601)))

            repo = searchResult.items.first
            group.leave()
        }
        
        group.wait()
        
        return repo!

    }
        
}

extension Endpoint where Target: TargetType {
    
    convenience init(mock target: Target, returning sampleResponse: EndpointSampleResponse) {
        self.init(url: URL(target: target).absoluteString, sampleResponseClosure: {sampleResponse}, method: target.method, task: target.task, httpHeaderFields: target.headers)
    }
    
}
