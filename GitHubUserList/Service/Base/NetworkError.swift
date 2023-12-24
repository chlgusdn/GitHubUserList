//
//  NetworkError.swift
//  GitHubUserList
//
//  Created by NUNU:D on 12/22/23.
//

import Foundation

/// API 호출 시 에러 케이스 enum
enum NetworkError: Error {
    case invaildURL
    case notModified
    case validationfailed
    case serverError
    case badCredential
    case unknown(message: String)
    
    var errorDescription: String {
        switch self {
        case .invaildURL:               return "유효하지 않은 URL입니다"
        case .notModified:              return "수정에 실패하였습니다"
        case .validationfailed:         return "유효성 검사에 실패하였습니다"
        case .serverError:              return "서비스를 이용할 수 없습니다"
        case .badCredential:            return "accessToken이 만료되었습니다"
        case .unknown(let message):     return message
        }
    }
}
