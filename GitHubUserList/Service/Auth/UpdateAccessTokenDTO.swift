//
//  UpdateAccessTokenDTO.swift
//  GitHubUserList
//
//  Created by NUNU:D on 12/24/23.
//

import Foundation
/// accessToken 업데이트 API에 사용될 DTO 구조체
struct UpdateAccessTokenDTO: Encodable {
    let clientId: String
    let clientSecret: String
    let refreshToken: String
    let grantType: String
    
    enum CodingKeys: String, CodingKey {
        case clientId                       = "client_id"
        case clientSecret                   = "client_secret"
        case refreshToken                   = "refresh_token"
        case grantType                      = "grant_type"
    }
}
