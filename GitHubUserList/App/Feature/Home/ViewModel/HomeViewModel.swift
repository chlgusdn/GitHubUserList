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
        let actionUserSearch = PublishRelay<String>()
        /// accessToken이 없을 경우
        let actionGetAcccessTokenPublish = PublishRelay<String>()
    }
    
    struct Output {
        /// 유저정보를 반환할 publish
        let userListPublish = PublishRelay<[User]>()
        /// emptyView showing여부값을 가질 relay { 기본값은 보여줌 }
        let showingEmptyViewRelay = BehaviorRelay(value: true)
    }
    
    var input = Input()
    var disposeBag = DisposeBag()
    var homeService: HomeService
    var authService: AuthService
    
    init(homeService: HomeService, authService: AuthService) {
        self.homeService = homeService
        self.authService = authService
        
    }
    
    func transform() -> Output {
        let output = Output()
        
        /// 유저정보 조회
        input.actionUserSearch
            .flatMap { [weak self] userName -> Single<SearchUser> in
                return self?.homeService.getSearchUser(userName: userName)
                    .catch { error in return .never() } ?? .never()
            }
            .subscribe(onNext: {
                if let users = $0.items {
                    output.userListPublish.accept(users)
                    output.showingEmptyViewRelay.accept(users.isEmpty)
                } else {
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
