//
//  AccessToken.swift
//  GitHubUserList
//
//  Created by NUNU:D on 12/22/23.
//

import Foundation

struct AccessToken: Decodable {
    let accessToken: String?
    let scope: String?
    let tokenType: String?
    
    enum CodingKeys: String, CodingKey {
        case accessToken    = "access_token"
        case scope          = "scope"
        case tokenType      = "token_type"
    }
}
