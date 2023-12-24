//
//  AuthAPI.swift
//  GitHubUserList
//
//  Created by NUNU:D on 12/24/23.
//

import Foundation
import Moya

/// accessToken, accestoken 업데이트 등 사용자 정보에 대한 API enum
enum AuthAPI {
    case getAccessToken(dto: AccessTokenDTO)
    case updateAccessToken(dto: UpdateAccessTokenDTO)
}

extension AuthAPI: BaseTargetType {
    var baseURL: URL {
        return URL(string: "https://github.com/login/oauth/")!
    }
    
    var path: String {
        return "access_token"
    }
    
    var task: Moya.Task {
        switch self {
        case .getAccessToken(let dto):          return .requestJSONEncodable(dto)
        case .updateAccessToken(let dto):       return .requestJSONEncodable(dto)
        }
    }
    
    var headers: [String : String]? {
        return [
            "Accept": "application/json"
        ]
    }
    
    var authorizationType: Moya.AuthorizationType? {
        return .basic
    }
    
    var method: Moya.Method {
        return .post
    }
}
