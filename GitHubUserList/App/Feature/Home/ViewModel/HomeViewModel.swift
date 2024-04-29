//
//  HomeViewModel.swift
//  GitHubUserList
//
//  Created by NUNU:D on 12/21/23.
//

import Foundation
import RxCocoa
import RxSwift

final class HomeViewModel: ViewModelType {
    struct Input {
        /// 유저정보 조회 시
        let actionUserSearchPublish = PublishRelay<String>()
        /// 유저 페이징 정보
        let actionUserPagingPublish = PublishRelay<Void>()
        /// accessToken이 없을 경우
        let actionGetAcccessTokenPublish = PublishRelay<String>()
    }
    
    struct Output {
        /// 유저정보를 반환할 publish
        let userListPublish = BehaviorRelay<[User]>(value: [])
        /// emptyView showing여부값을 가질 relay { 기본값은 보여줌 }
        let showingEmptyViewRelay = BehaviorRelay(value: true)
        /// 에러에 대한 publish
        let errorPublish = PublishRelay<NetworkError>()
    }
    
    // MARK: ViewModel에서 사용할 private 변수
    private var currentPage = 1      /// 현재 페이징 카운트
    private var totalCount = 0       /// 리스트의 총 크기 값
    private var lastSearchText = ""  /// 마지막으로 검색한 텍스트 데이터
    private var homeService: HomeService
    private var authService: AuthService
    
    var input = Input()
    var disposeBag = DisposeBag()
    
    init(homeService: HomeService, authService: AuthService) {
        self.homeService = homeService
        self.authService = authService
    }
    
    func transform() -> Output {
        let output = Output()
    
        // 유저 페이징 observable
        input.actionUserPagingPublish
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.currentPage += 1
                self.input.actionUserSearchPublish.accept(self.lastSearchText)
            })
            .disposed(by: disposeBag)
        
        /// 유저 정보 조회
        input.actionUserSearchPublish
            .withUnretained(self)
            .flatMap { (self, userName) -> Single<Result<SearchUser, NetworkError>> in
                // 기존 검색어가 아닌 새로운 검색어 입력 시 값 초기화
                if self.lastSearchText != userName {
                    self.currentPage = 1
                    self.totalCount = 0
                    output.userListPublish.accept([])
                    self.lastSearchText = userName
                }
                
                // totalCount보다 userList가 더 많거나 같으면 API를 호출하지 않음
                if self.totalCount > 0 &&
                    self.totalCount <= output.userListPublish.value.count {
                    return .never()
                }
                
                return self.homeService.getSearchUser(userName: userName, page: self.currentPage)
            }
            .withUnretained(self)
            .subscribe(onNext: { (self, result) in
                if case .success(let searchUser) = result {
                    if let users = searchUser.items {
                        /// viewModel에서 체크할 totalCount
                        self.totalCount = searchUser.totalCount ?? users.count
                        /// 현재 유저 + 페이징에서 조회한 유저 정보
                        let totalUsers = output.userListPublish.value + users
                        
                        output.userListPublish.accept(totalUsers)
                        output.showingEmptyViewRelay.accept(totalUsers.isEmpty)
                    }
                    else {
                        output.showingEmptyViewRelay.accept(true)
                    }
                }
            })
            .disposed(by: disposeBag)
        
        /// callback으로 받아온 code값을 가지고 accessToken을 저장
        input.actionGetAcccessTokenPublish
            .withUnretained(self)
            .flatMap { (self, code) -> Single<Result<AccessToken, NetworkError>> in
                let dto = AccessTokenDTO(
                    clientId: Constant.clientId,
                    clientSecret: Constant.clientSecret,
                    code: code
                )
                
                return self.authService.getAccessToken2Result(dto: dto)
            }
            .subscribe(onNext: { result in
                switch result {
                case .success(let response):
                    if let accessToken = response.accessToken,
                       let refreshToken = response.refreshToken {
                        KeychainUtil.create(key: .accessToken, token: accessToken)
                        KeychainUtil.create(key: .refreshToken, token: refreshToken)
                    }
                    else {
                        output.errorPublish.accept(.unknown(message: "accessToken 또는 refreshToken값을 가져오지 못했습니다"))
                    }
                    
                case .failure(let error):
                    output.errorPublish.accept(error)
                }
            })
            .disposed(by: disposeBag)
            
        
        return output
    }
}
