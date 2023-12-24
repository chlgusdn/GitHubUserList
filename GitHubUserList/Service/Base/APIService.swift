//
//  APIService.swift
//  GitHubUserList
//
//  Created by NUNU:D on 12/22/23.
//

import Foundation
import RxMoya
import Moya
import RxSwift

/**
 * - Description: APIRequest를 위한 MoyaProvider와 request함수를 제공해주는 BaseAPIService
 */
class BaseAPIService<Target: BaseTargetType> {
    var provider: MoyaProvider<Target>
    
    /**
     * - Description : BaseAPIService에서 테스트코드를 위한 이니셜라이저
     * - Parameter isSutub 테스트 여부 {테스트 용 인지} 기본값으로는 `false`
     * - Parameter sampleStatusCode HTTPStatusCode값 기본값으로는 `200`
     * - Parameter customEndPointClosure  엔드포인트에 대한 클로저 함수 기본값은 `nil`
     */
    init(isStub: Bool = false, sampleStatusCode: Int = 200, customEndPointClosure: ((Target) -> Endpoint)? = nil) {
        if (!isStub) {
            // accessToken Setting
            let authPlugin = AccessTokenPlugin { _ in
                guard let accessToken = KeychainUtil.read(key: .accessToken) else {
                    return ""
                }
                return accessToken
            }
            
            // networklogger Setting
            let loggerPlugin = NetworkLoggerPlugin()
            let requestInterceptor = APIRequestInterceptor()
            let session = Session(interceptor: requestInterceptor)
            
            provider = MoyaProvider<Target>(session: session, plugins: [loggerPlugin, authPlugin])
        }
        else {
            let endPointClosure = { (target:Target) -> Endpoint in
                let smapleResponseClosure: () -> EndpointSampleResponse = {
                    EndpointSampleResponse.networkResponse(sampleStatusCode, target.sampleData)
                }
                
                return Endpoint(url: URL(target: target).absoluteString,
                                sampleResponseClosure: smapleResponseClosure,
                                method: target.method, task: target.task,
                                httpHeaderFields: target.headers)
                
            }
            
            provider = MoyaProvider<Target>(endpointClosure: customEndPointClosure ?? endPointClosure,
                                            stubClosure: MoyaProvider.immediatelyStub)
        }
    }
    
    /**
     * - Description: 페이징이 필요한 HTTP Request + DTO변환이 필요한 Request 메서드
     * - Parameter type: APITarget
     * - Parameter responseType: HTTP Request시 디코딩할 객체 타입
     * - Returns Single로 Wrapping + BasePagenationResponse객체로 Wrapping한 Response 객체의 DTO 배열 객체
     */
    func singleRequest<D: Decodable>(_ type: Target, responseType: D.Type) -> Single<D> {
        return provider
            .rx
            .request(type)
            .timeout(.seconds(30), scheduler: MainScheduler.instance)
            .filterSuccessfulStatusCodes()
            .map(responseType)
            .catch { throw self.networkErrorHandling(error: $0) }
    }
    
    /**
     * - Description 에러 관련 하여 `NetworkError` Enum 컨버팅 함수
     * - Returns NetworkError
     */
    private func networkErrorHandling(error: Error) -> NetworkError {
        guard let moyaError = error as? MoyaError else {
            return NetworkError.unknown(message: error.localizedDescription)
        }
        
        guard let response = moyaError.response,
              let errDescription = moyaError.errorDescription else {
            return NetworkError.invaildURL
        }
        
        return restAPIErrorHandling(code: response.statusCode, message: errDescription)
    }
    
    /**
     * - Description REST API에서 발생된 statusCode를 가지고 `Network`Enum 컨버팅 함수
     * - Returns NetworkError
     */
    private func restAPIErrorHandling(code: Int, message: String) -> NetworkError {
        switch code {
        case 304:
            return NetworkError.notModified
        case 422:
            return NetworkError.validationfailed
        case 503:
            return NetworkError.serverError
        case 401:
            return NetworkError.badCredential
        default:
            return NetworkError.unknown(message: message)
        }
    }
}
