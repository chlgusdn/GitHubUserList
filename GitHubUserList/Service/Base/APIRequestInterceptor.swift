//
//  APIRequestInterceptor.swift
//  GitHubUserList
//
//  Created by NUNU:D on 12/23/23.
//

import UIKit
import Alamofire
import RxSwift

/// API Request시 특정 에러일 경우 해당 request를 캐치하여 특정작업 후 다시시도하도록하는 클래스
final class APIRequestInterceptor: RequestInterceptor {
    
    let disposeBag = DisposeBag()
    
    func adapt(_ urlRequest: URLRequest, using state: RequestAdapterState, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        completion(.success(urlRequest))
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        guard let statusCode = request.response?.statusCode,
              statusCode == 401 else {
            completion(.doNotRetry)
            return
        }
        
        let authService = AuthService()
        if let refreshToken =  KeychainUtil.read(key: .refreshToken) {
            let updateDTO = UpdateAccessTokenDTO(
                clientId: Constant.clientId,
                clientSecret: Constant.clientSecret,
                refreshToken: refreshToken,
                grantType: "refresh_token"
            )
            
            /// 해당 API는 스트림이 끊겨도 상관없기 때문에 Result 타입이 아닌 Single<D>타입으로 진행
            authService.updateAccessToken(dto: updateDTO)
                .subscribe(onSuccess: {
                    if let accessToken = $0.accessToken,
                       let refreshToken = $0.refreshToken {
                        KeychainUtil.update(key: .accessToken, token: accessToken)
                        KeychainUtil.update(key: .refreshToken, token: refreshToken)
                        completion(.retry)
                    }
                    else {
                        completion(.doNotRetryWithError(NetworkError.unknown(message: "accessToken, refreshToken이 존재하지 않습니다")))
                    }
                    
                }, onFailure: {
                    completion(.doNotRetryWithError(NetworkError.unknown(message: $0.localizedDescription)))
                })
                .disposed(by: disposeBag)
        }
        
        
    }
}
