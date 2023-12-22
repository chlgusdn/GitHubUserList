//
//  User.swift
//  GitHubUserList
//
//  Created by NUNU:D on 12/22/23.
//

import Foundation

/// 유저 정보 모델 구조체
struct User: Decodable {
    let login: String?
    let id: Int?
    let nodeId: String?
    let avatarURL: String?
    let gravatarId: String?
    let url: String?
    let htmlURL: String?
    let followersURL: String?
    let subscriptionsURL: String?
    let organizationsURL: String?
    let reposURL: String?
    let receivedEventsURL: String?
    let type: String?
    let score: Double?
    let followingURL: String?
    let gistsURL: String?
    let starredURL: String?
    let eventsURL: String?
    let siteAdmin: Bool?
    
    enum CodingKeys: String, CodingKey {
        case login                      = "login"
        case id                         = "id"
        case nodeId                     = "node_id"
        case avatarURL                  = "avatar_url"
        case gravatarId                 = "gravatar_id"
        case url                        = "url"
        case htmlURL                    = "html_url"
        case followersURL               = "followers_url"
        case subscriptionsURL           = "subscriptions_url"
        case organizationsURL           = "organizations_url"
        case reposURL                   = "repos_url"
        case receivedEventsURL          = "received_events_url"
        case type                       = "type"
        case score                      = "score"
        case followingURL               = "following_url"
        case gistsURL                   = "gists_url"
        case starredURL                 = "starred_url"
        case eventsURL                  = "events_url"
        case siteAdmin                  = "site_admin"
    }
}
