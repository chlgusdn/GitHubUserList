//
//  SearchUser.swift
//  GitHubUserList
//
//  Created by NUNU:D on 12/22/23.
//

import Foundation

/// 유저 정보 조회 API의 모델 구조체
struct SearchUser: Decodable {
    let totalCount: Int?
    let inCompleteResult: Bool?
    let items: [User]?
    
    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case inCompleteResult = "incomplete_results"
        case items
    }
}
