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
    case searchUser(name: String, page: Int = 1)
}

extension GitHubAPI: BaseTargetType {
    var baseURL: URL {
        return URL(string: "https://api.github.com/")!
    }
    
    var path: String {
        return "search/users"
    }
    
    var task: Moya.Task {
        switch self {
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
        return [
            "Accept" : "application/vnd.github+json"
        ]
    }
    
    var method: Moya.Method {
        return .get
    }
}
