//
//  AccessTokenDTO.swift
//  GitHubUserList
//
//  Created by NUNU:D on 12/22/23.
//

import Foundation

/// accessToken API에 사용될 DTO 구조체
struct AccessTokenDTO: Encodable {
    let clientId: String
    let clientSecret: String
    let code: String
    
    enum CodingKeys: String, CodingKey {
        case clientId                       = "client_id"
        case clientSecret                   = "client_secret"
        case code                           = "code"
    }
}
