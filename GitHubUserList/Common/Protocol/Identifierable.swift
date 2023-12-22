//
//  Identifierable.swift
//  GitHubUserList
//
//  Created by NUNU:D on 12/21/23.
//

import Foundation

/// CollectionView, TableView, ReusableView와 같은 셀 등록 시 identifier를 가지는 클래스에 대해서 기본적으로 가지는 identifier 프로토콜
protocol Identifierable: AnyObject {
    static var identifier: String { get }
}

/// identifier를 자신의 클래스 명으로 지정하도록하는 extension
extension Identifierable {
    static var identifier: String {
        return String(describing: self)
    }
}
