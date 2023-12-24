//
//  HomeScreenTest.swift
//  GitHubUserListTests
//
//  Created by NUNU:D on 12/24/23.
//

import XCTest
import Moya
import RxSwift
@testable import GitHubUserList

final class HomeScreenTest: XCTestCase {

    var homeService: HomeService!
    var authService: AuthService!
    var viewModel: HomeViewModel!
    var searchUser: SearchUser!
    var expectation: XCTestExpectation!
    
    override func setUpWithError() throws {
        let user = User(
            login: "mojombo",
            id: 1,
            nodeId: "MDQ6VXNlcjE=",
            avatarURL: "https://secure.gravatar.com/avatar/25c7c18223fb42a4c6ae1c8db6f50f9b?d=https://a248.e.akamai.net/assets.github.com%2Fimages%2Fgravatars%2Fgravatar-user-420.png",
            gravatarId: "",
            url: "https://api.github.com/users/mojombo",
            htmlURL: "https://github.com/mojombo",
            followersURL: "https://api.github.com/users/mojombo/followers",
            subscriptionsURL: "https://api.github.com/users/mojombo/subscriptions",
            organizationsURL: "https://api.github.com/users/mojombo/orgs",
            reposURL: "https://api.github.com/users/mojombo/repos",
            receivedEventsURL: "https://api.github.com/users/mojombo/received_events",
            type: "User",
            score: 1,
            followingURL: "https://api.github.com/users/mojombo/following{/other_user}",
            gistsURL: "https://api.github.com/users/mojombo/gists{/gist_id}",
            starredURL: "https://api.github.com/users/mojombo/starred{/owner}{/repo}",
            eventsURL: "ttps://api.github.com/users/mojombo/events{/privacy}",
            siteAdmin: true
        )
        searchUser = SearchUser(
            totalCount: 7,
            inCompleteResult: false,
            items: [user]
        )
        
        expectation = XCTestExpectation()
    }
    
    func test_응답값이_정상일경우_유저리스트는_값이있어야합니다() {
        // given
        homeService = HomeService(isStub: true, sampleStatusCode: 200)
        authService = AuthService(isStub: true, sampleStatusCode: 200)
        viewModel = HomeViewModel(homeService: homeService, authService: authService)
        
        // when
        let output = viewModel.transform()
        viewModel.input.actionUserSearchPublish.accept("")
        
        // then
        output.userListPublish.subscribe(onNext: { [unowned self] result in
            XCTAssertEqual(searchUser.items?.count, result.count)
            expectation.fulfill()
        })
        .dispose()
        
        wait(
            for: [expectation],
            timeout: 2.0
        )
    }
    
    func test_응답값이_에러인경우_유저리스트는_빈값이여야합니다() {
        //given
        homeService = HomeService(isStub: true, sampleStatusCode: 403)
        authService = AuthService(isStub: true, sampleStatusCode: 200)
        viewModel = HomeViewModel(homeService: homeService, authService: authService)
        
        //when
        let output = viewModel.transform()
        viewModel.input.actionUserSearchPublish.accept("")
        
        //then
        output.userListPublish
            .subscribe(onNext: { [unowned self] result in
                XCTAssertTrue(result.isEmpty)
                expectation.fulfill()
            })
            .dispose()
        
        wait(
            for: [expectation],
            timeout: 2.0
        )
    }
    
    func test_응답값이_정상일경우_emptyView는_false이여야합니다() {
        //given
        homeService = HomeService(isStub: true, sampleStatusCode: 200)
        authService = AuthService(isStub: true, sampleStatusCode: 200)
        viewModel = HomeViewModel(homeService: homeService, authService: authService)
        
        //when
        let output = viewModel.transform()
        viewModel.input.actionUserSearchPublish.accept("")
        
        //then
        output.showingEmptyViewRelay
            .subscribe(onNext: { [unowned self] isShow in
                XCTAssertFalse(isShow)
                expectation.fulfill()
            })
            .dispose()
        
        wait(
            for: [expectation],
            timeout: 2.0
        )
    }
    
    func test_응답값이_에러인경우_emptyView는_true이여야합니다() {
        //given
        homeService = HomeService(isStub: true, sampleStatusCode: 403)
        authService = AuthService(isStub: true, sampleStatusCode: 200)
        viewModel = HomeViewModel(homeService: homeService, authService: authService)
        
        //when
        let output = viewModel.transform()
        viewModel.input.actionUserSearchPublish.accept("")
        
        //then
        output.showingEmptyViewRelay
            .subscribe(onNext: { [unowned self] isShow in
                XCTAssertTrue(isShow)
                expectation.fulfill()
            })
            .dispose()
        
        wait(
            for: [expectation],
            timeout: 2.0
        )
    }

    func test_응답값이_정상이지만_값이없을경우에는_emptyView는_true이여야합니다() {
        //given
        homeService = HomeService(isStub: true) { target in
            return Endpoint(
                url: target.baseURL.absoluteString,
                sampleResponseClosure: {
                    EndpointSampleResponse.networkResponse(
                        200,
                        """
                            {
                                "total_count":0,
                                "incomplete_results":false,
                                "items":[]
                            }
                        """.data(using: .utf8)!
                    )
                },
                method: target.method,
                task: target.task,
                httpHeaderFields: target.headers
            )
        }
        authService = AuthService(isStub: true, sampleStatusCode: 200)
        viewModel = HomeViewModel(homeService: homeService, authService: authService)
        
        //when
        let output = viewModel.transform()
        viewModel.input.actionUserSearchPublish.accept("")
        
        //then
        output.showingEmptyViewRelay
            .subscribe(onNext: { [unowned self] isShow in
                XCTAssertTrue(isShow)
                expectation.fulfill()
            })
            .dispose()
        
        wait(
            for: [expectation],
            timeout: 2.0
        )
    }
    
    func test_accessToken값이_null이면_errorPopUp을띄워야합니다() {
        //given
        homeService = HomeService(isStub: true, sampleStatusCode: 200)
        authService = AuthService(isStub: true) { target in
            return Endpoint(
                url: target.baseURL.absoluteString,
                sampleResponseClosure: {
                    EndpointSampleResponse.networkResponse(
                        200,
                        """
                            {
                              "access_token": null,
                              "scope":"repo,gist",
                              "token_type":"bearer"
                            }
                        """.data(using: .utf8)!
                    )
                },
                method: target.method,
                task: target.task,
                httpHeaderFields: target.headers
            )
        }
        viewModel = HomeViewModel(homeService: homeService, authService: authService)
        
        //when
        let output = viewModel.transform()
        viewModel.input.actionGetAcccessTokenPublish.accept("token")
        //then
        output.errorPublish.subscribe(onNext: { [unowned self] error in
            XCTAssertEqual(error.errorDescription, "accessToken을 가져오지 못했습니다")
            expectation.fulfill()
        })
        .dispose()
    }
    
    func test_accessToken에러발생시_에러에_해당하는_오류팝업을띄워야합니다() {
        //given
        homeService = HomeService(isStub: true, sampleStatusCode: 200)
        authService = AuthService(isStub: true) { target in
            return Endpoint(
                url: target.baseURL.absoluteString,
                sampleResponseClosure: {
                    EndpointSampleResponse.networkResponse(
                        503,
                        """
                            {
                              "access_token": "accessToken",
                              "scope":"repo,gist",
                              "token_type":"bearer"
                            }
                        """.data(using: .utf8)!
                    )
                },
                method: target.method,
                task: target.task,
                httpHeaderFields: target.headers
            )
        }
        viewModel = HomeViewModel(homeService: homeService, authService: authService)
        
        //when
        let output = viewModel.transform()
        viewModel.input.actionGetAcccessTokenPublish.accept("code")
        //then
        output.errorPublish.subscribe(onNext: { [unowned self] error in
            XCTAssertEqual(error.errorDescription, "서비스를 이용할 수 없습니다")
            expectation.fulfill()
        })
        .dispose()
    }
}
