//
//  ViewModelType.swift
//  GitHubUserList
//
//  Created by NUNU:D on 12/21/23.
//

import Foundation
import RxSwift

/// ViewModel에 I.O 패턴을 적용하기 위한 프로토콜
/// `transform` 메서드를 통해 output 객체 생성하여 실제 view에 바인딩
protocol ViewModelType: AnyObject {
    /// 사용자 Input
    associatedtype Input
    /// 사용자 Output (실제 View)에 바인딩할 객체
    associatedtype Output
    /// 사용자가 입력한 Input 정보
    /// ```
    /// input.observable.onNext(객체) 등
    /// ```
    var input: Input { get }
    var disposeBag: DisposeBag { get }
    /// 사용자 인풋을 가져와서 output으로 배출시키는 함수 이 output을 가져와   View 객체에 바인딩
    func transform() -> Output
}
