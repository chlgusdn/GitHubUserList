//
//  BaseTarget.swift
//  GitHubUserList
//
//  Created by NUNU:D on 12/21/23.
//

import Foundation
import Moya

/// API 선언 시 추가적으로 선언하지 않아도 기본 할당되어있는 베이스 프로토콜
protocol BaseTargetType: TargetType, AccessTokenAuthorizable {}

extension BaseTargetType {
    ///HTTP 성공 타입 (기본 200~299)까지 성공
    var validationType: ValidationType {
        return .successAndRedirectCodes
    }
    
    /// HTTP Method
    var method: Moya.Method {
        return .post
    }
    
    /// Header에 표기될 Authorization 타입 
    var authorizationType: AuthorizationType? {
        return .bearer
    }
}
