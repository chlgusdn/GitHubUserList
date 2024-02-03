//
//  AuthService.swift
//  GitHubUserList
//
//  Created by NUNU:D on 12/24/23.
//

import Foundation
import RxSwift

/// 사용자 정보 관련한 API 서비스 클래스
final class AuthService: BaseAPIService<AuthAPI> {
    
    /// accessToken을 업데이트할 API
    func updateAccessToken(dto: UpdateAccessTokenDTO) -> Single<AccessToken> {
        return singleRequest(.updateAccessToken(dto: dto), responseType: AccessToken.self)
    }
    
    /// accessToken을 조회할 API
    func getAccessToken2Result(dto: AccessTokenDTO) -> Single<Result<AccessToken, NetworkError>> {
        return singleRequest(.getAccessToken(dto: dto), responseType: AccessToken.self)
    }
}
