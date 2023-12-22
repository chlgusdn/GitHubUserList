//
//  UILayoutable.swift
//  GitHubUserList
//
//  Created by NUNU:D on 12/21/23.
//

import Foundation

/**
 * #UILayout 설정하는 부분과 bind하는 부분을 나누기 위한 Protocol
 */
protocol UILayoutable {
    /// 각종 View에 대한 프로퍼티를 설정하기 위한 메서드
    func setUpProperty()
    /// View에 대한 레이아웃을 설정하기 위한 메서드
    func setUpLayout()
    /// View에 대한 AutoLayout을 설정하기 위한 메서드
    func setUpConstraint()
    /// ViewModel과 rx 바인딩을 설정하기 위한 메서드
    func setBind()
}

/// 특정 View의 경우 메서드 전부가 필요하지 않기 때문에 옵셔널로 처리하기 위한 Extension
extension UILayoutable {
    func setUpProperty() {}
    func setUpLayout() {}
    func setUpConstraint() {}
    func setBind() {}
    
    /// UI 세팅에 대한 함수를 한번에 불러오기 위한 함수
    /// 뷰에 세팅할때마다 각종 뷰에 대한 함수를 호출해줘야하기 때문에 한번에 호출하기 위함
    func allSetUp() {
        setUpProperty()
        setUpLayout()
        setUpConstraint()
        setBind()
    }
}
