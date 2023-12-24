//
//  AccessToken.swift
//  GitHubUserList
//
//  Created by NUNU:D on 12/22/23.
//

import Foundation

/**
 * - description accessToken API 리스폰스 객체
 */
struct AccessToken: Decodable {
    let refreshToken: String?
    let refreshTokenExpiresIn: Int?
    let expiresIn: Int?
    let accessToken: String?
    let scope: String?
    let tokenType: String?
    
    enum CodingKeys: String, CodingKey {
        case refreshToken                       = "refresh_token"
        case refreshTokenExpiresIn              = "refresh_token_expires_in"
        case expiresIn                          = "expires_in"
        case accessToken                        = "access_token"
        case scope                              = "scope"
        case tokenType                          = "token_type"
    }
}
