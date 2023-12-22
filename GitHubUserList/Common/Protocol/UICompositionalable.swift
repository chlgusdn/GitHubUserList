//
//  UICompositionalable.swift
//  GitHubUserList
//
//  Created by NUNU:D on 12/21/23.
//

import UIKit

/// CollectionView에 적용할 CompositionalLayout 생성 프로토콜
protocol UICompositionalable: AnyObject {
    /// `CompositionalLayout`을 적용하기 위한 CompositionalLayout 객체 생성 함수
    func compositionalLayout() -> UICollectionViewCompositionalLayout
}
