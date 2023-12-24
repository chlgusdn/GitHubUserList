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
    
    var sampleData: Data {
        switch self {
        case .searchUser:
            return """
                    {
                        "total_count":7,
                        "incomplete_results":false,
                        "items":[
                            {
                                "login":"mojombo",
                                "id":1,
                                "node_id":"MDQ6VXNlcjE=",
                                "avatar_url":"https://secure.gravatar.com/avatar/25c7c18223fb42a4c6ae1c8db6f50f9b?d=https://a248.e.akamai.net/assets.github.com%2Fimages%2Fgravatars%2Fgravatar-user-420.png",
                                "gravatar_id":"",
                                "url":"https://api.github.com/users/mojombo",
                                "html_url":"https://github.com/mojombo",
                                "followers_url":"https://api.github.com/users/mojombo/followers",
                                "subscriptions_url":"https://api.github.com/users/mojombo/subscriptions",
                                "organizations_url":"https://api.github.com/users/mojombo/orgs",
                                "repos_url":"https://api.github.com/users/mojombo/repos",
                                "received_events_url":"https://api.github.com/users/mojombo/received_events",
                                "type":"User",
                                "score":1,
                                "following_url":"https://api.github.com/users/mojombo/following{/other_user}",
                                "gists_url":"https://api.github.com/users/mojombo/gists{/gist_id}",
                                "starred_url":"https://api.github.com/users/mojombo/starred{/owner}{/repo}",
                                "events_url":"https://api.github.com/users/mojombo/events{/privacy}",
                                "site_admin":true
                            }
                        ]
                    }
                    """.data(using: .utf8)!
        }
    }
}
