//
//  NetworkLoggerPlugin.swift
//  GitHubUserList
//
//  Created by NUNU:D on 12/22/23.
//

import Foundation
import Moya

/**
 * - Description: NetworkLogger  플러그인
 */
struct NetworkLoggerPlugin: PluginType {
    
    func willSend(_ request: RequestType, target: TargetType) {
        guard let httpRequest = request.request else {
            print("HTTP Request Invalid Request")
            return
        }
        
        let url = httpRequest.description
        let method = httpRequest.httpMethod ?? "__unknown_method__"
        
        print( """
            \n▼ [HTTP Request]
            - [URL] : \(url)
            - [TARGET] : \(target)
            - [METHOD] : \(method)
            - [HEADER] : \(httpRequest.headers.dictionary )
            - [BODY] : \(httpRequest.httpBody?.toPrettyPrintedString ?? "__none__")
            --------------------------------------
            """)
    }
    
    func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        switch result {
        case let .success(response):
            onSuccesed(response, target: target, isFromError: false)
            
        case let .failure(error):
            onFailed(error, target: target)
        }
    }
    
    /**
     * - Description: API가 성공적으로 리턴했을때의 메서드로 리턴된 statusCode가 401일 경우 엑세스, 리프레시토큰을 갱신해줌
     * - Parameter response: API에서 리턴된 Response객체
     * - Parameter target: API를실행하는 `TargetType`객체
     * - Parameter isFromError: 에러가 발생여부
     */
    private func onSuccesed(_ response: Response, target: TargetType, isFromError: Bool) {
        let request = response.request
        let url = request?.url?.absoluteString ?? "nil"
        let statusCode = response.statusCode
        
        print( """
            \n▼ [HTTP Response]
            - [URL] : \(url)
            - [TARGET] : \(target)
            - [STATUSCODE] : \(statusCode )
            - [RESPONSE DATA] : \(response.data.toPrettyPrintedString ?? "__none__")
            --------------------------------------
            """)

    }
    
    /**
     * - Description: API가 실패하였을 경우 실행하는 메서드
     * - Parameter error: API에서 리턴된 `MoyaError`객체
     * - Parameter target: API를실행하는 `TargetType`객체
     */
    private func onFailed(_ error: MoyaError, target: TargetType) {
        if let response = error.response {
            onSuccesed(response, target: target, isFromError: true)
            return
        }
        
        print("""
            \n▼ [HTTP ERROR]
            - [TARGET] : \(target)
            - [ERROR CODE] : \(error.errorCode)
            - [ERROR MESSAGE] : \(error.failureReason ?? error.errorDescription ?? "__unknown__error__")
            --------------------------------------
            """)
    }
}

extension Data {
    var toPrettyPrintedString: String? {
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
              let prettyPrintedString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else { return nil }
        return prettyPrintedString as String
    }
}
