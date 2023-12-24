//
//  HomeService.swift
//  GitHubUserList
//
//  Created by NUNU:D on 12/22/23.
//

import Foundation
import RxSwift

final class HomeService: BaseAPIService<GitHubAPI> {
    /// 유저 정보 조회 API
    func getSearchUser(userName: String, page: Int = 1) -> Single<SearchUser> {
        return singleRequest(.searchUser(name: userName, page: page), responseType: SearchUser.self)
    }
}
