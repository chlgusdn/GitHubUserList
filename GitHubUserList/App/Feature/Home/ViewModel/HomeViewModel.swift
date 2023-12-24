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
            .subscribe(onNext: { [weak self] in
                guard let `self` = self else { return }
                currentPage += 1
                input.actionUserSearchPublish.accept(lastSearchText)
            })
            .disposed(by: disposeBag)
        
        /// 유저 정보 조회
        input.actionUserSearchPublish
            .flatMap { [weak self] userName -> Single<SearchUser> in
                guard let `self` = self else { return .never() }
                
                // 기존 검색어가 아닌 새로운 검색어 입력 시 값 초기화
                if lastSearchText != userName {
                    currentPage = 1
                    totalCount = 0
                    output.userListPublish.accept([])
                    lastSearchText = userName
                }
                
                // totalCount보다 userList가 더 많거나 같으면 API를 호출하지 않음
                if totalCount > 0 &&
                    totalCount <= output.userListPublish.value.count {
                    return .never()
                }
                
                return homeService.getSearchUser(
                    userName: userName,
                    page: currentPage
                ).catch { error in return .never() }
            }
            .subscribe(onNext: { [weak self] searchUser in
                if let users = searchUser.items {
                    /// viewModel에서 체크할 totalCount
                    self?.totalCount = searchUser.totalCount ?? users.count
                    /// 현재 유저 + 페이징에서 조회한 유저 정보
                    let totalUsers = output.userListPublish.value + users
                    
                    output.userListPublish.accept(totalUsers)
                    output.showingEmptyViewRelay.accept(totalUsers.isEmpty)
                }
                else {
                    output.showingEmptyViewRelay.accept(true)
                }
            })
            .disposed(by: disposeBag)
        
        /// callback으로 받아온 code값을 가지고 accessToken을 저장
        input.actionGetAcccessTokenPublish
            .flatMap { [weak self] code -> Single<AccessToken> in
                let dto = AccessTokenDTO(
                    clientId: Constant.clientId,
                    clientSecret: Constant.clientSecret,
                    code: code
                )
                return self?.authService.getAccessToken(dto: dto)
                    .catch { _ in return .never() } ?? .never()
            }
            .subscribe(onNext: {
                if let accessToken = $0.accessToken {
                    KeychainUtil.create(key: .accessToken, token: accessToken)
                }
            })
            .disposed(by: disposeBag)
            
        
        return output
    }
}
