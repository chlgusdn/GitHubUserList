//
//  EmptyView.swift
//  GitHubUserList
//
//  Created by NUNU:D on 12/22/23.
//

import UIKit

/// 데이터가 존재하지 않을 경우에 사용할 화면
final class EmptyView: UIView {

    private let emptyImageView = UIImageView().then {
        $0.image = UIImage(systemName: "questionmark.circle")
        $0.tintColor = .darkGray
    }
    
    private let emptyLabel = UILabel().then {
        $0.text = "검색된 유저가 없습니다"
        $0.font = UIFont.boldSystemFont(ofSize: 16)
        $0.textColor = .darkGray
    }
    
    init(message: String) {
        super.init(frame: .zero)
        emptyLabel.text = message
        allSetUp()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        allSetUp()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension EmptyView: UILayoutable {
    func setUpLayout() {
        [emptyLabel, emptyImageView].forEach {
            addSubview($0)
        }
    }
    
    func setUpConstraint() {
        emptyImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.size.equalTo(60)
        }
        
        emptyLabel.snp.makeConstraints {
            $0.top.equalTo(emptyImageView.snp.bottom).offset(15)
            $0.center.equalToSuperview()
        }
    }
}
@available(iOS 17.0, *)
#Preview(traits: .fixedLayout(width: 414, height: 200), body: {
    EmptyView()
})
