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
            
            provider = MoyaProvider<Target>(
                requestClosure: { endpoint, closure in
                    do {
                        // 30초 타임아웃 설정
                        var request = try endpoint.urlRequest()
                        request.timeoutInterval = 30
                        closure(.success(request))
                    }
                    catch {
                        closure(.failure(MoyaError.underlying(error, nil)))
                    }
                },
                session: session,
                plugins: [
                    loggerPlugin,
                    authPlugin
                ]
            )
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
     * - Description: HTTP Request  메서드 (스트림이 끊겨도 되는 경우에 사용)
     * - Parameter type: APITarget
     * - Parameter responseType: HTTP Request시 디코딩할 객체 타입
     * - Returns Single로 Wrapping 객체로 Wrapping한 Response 객체
     */
    func singleRequest<D: Decodable>(_ type: Target, responseType: D.Type) -> Single<D> {
        return provider
            .rx
            .request(type)
            .filterSuccessfulStatusCodes()
            .map(responseType)
            .catch { throw self.networkErrorHandling(error: $0) }
    }
    
    /**
     * - Description: HTTP Request  메서드 (스트림이 끊기면 안되는 경우에 사용)
     * - Parameter type: APITarget
     * - Parameter responseType: HTTP Request시 디코딩할 객체 타입
     * - Returns Single로 Wrapping 객체로 Wrapping한 Response 객체
     */
    func singleRequest<D: Decodable>(_ type: Target, responseType: D.Type) -> Single<Result<D, NetworkError>> {
        return Single<Result<D, NetworkError>>.create { [weak self] single in
            
            guard let `self` = self else { return Disposables.create() }
            
            let cancelable = provider.request(type) { result in
                var returnResult: Result<D, NetworkError>
                switch result {
                case .success(let response):
                    // 200 ~ 300 사이 일경우
                    if (200...300) ~= response.statusCode {
                        guard let responseData = try? JSONDecoder().decode(responseType.self, from: response.data) else {
                            returnResult = .failure(NetworkError.unknown(message: "데이터 디코드 에러입니다"))
                            single(.success(returnResult))
                            return
                        }
                        
                        returnResult = .success(responseData)
                        single(.success(returnResult))
                    }
                    else {
                        let error = self.restAPIErrorHandling(code: response.statusCode, message: "[\(response.statusCode)] 오류 입니다")
                        returnResult = .failure(error)
                        single(.success(returnResult))
                    }
                    
                case .failure(let moyaError):
                    let error = self.networkErrorHandling(error: moyaError)
                    returnResult = .failure(error)
                    single(.success(returnResult))
                }
            }
            
            return Disposables.create {
                cancelable.cancel()
            }
        }
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
