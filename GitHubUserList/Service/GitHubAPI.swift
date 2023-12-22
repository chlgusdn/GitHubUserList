//
//  GitHubAPI.swift
//  GitHubUserList
//
//  Created by NUNU:D on 12/21/23.
//

import Foundation
import Moya

/// GitHub OpenAPI에 관한 API 명 enum
enum GitHubAPI {
    case getAccessToken(dto: AccessTokenDTO)
    case searchUser(name: String, page: Int = 1)
}

extension GitHubAPI: BaseTargetType {
    var baseURL: URL {
        switch self {
        case .getAccessToken:                       return URL(string: "https://github.com/login/oauth/")!
        case .searchUser:                           return URL(string: "https://api.github.com/")!
        }
    }
    
    var path: String {
        switch self {
        case .getAccessToken:                       return "access_token"
        case .searchUser:                           return "search/users"
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .getAccessToken(let dto):
            return .requestParameters(
                parameters: [
                    "client_id": dto.clientId,
                    "client_secret": dto.clientSecret,
                    "code": dto.code
                ],
                encoding: URLEncoding.httpBody)
            
        case .searchUser(let name, let page):
            return .requestParameters(
                parameters: [
                    "q": name,
                    "page": page
                ],
                encoding: URLEncoding.queryString
            )
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .getAccessToken:
            return [
                "Accept": "application/json"
            ]
        case .searchUser:
            return [
                "Accept" : "application/vnd.github+json"
            ]
        }
    }
    
    var authorizationType: Moya.AuthorizationType? {
        switch self {
        case .getAccessToken:               return .basic
        default:                            return .bearer
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .searchUser:   return .get
        default:            return .post
        }
    }
}
