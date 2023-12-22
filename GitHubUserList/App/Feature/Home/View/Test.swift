//
//  HomeEmptyView.swift
//  TodayDiary
//
//  Created by NUNU:D on 11/6/23.
//

import UIKit

final class HomeEmptyView: UIView {
    
    lazy var emptyImageView = UIImageView().then {
        $0.image = UIImage(systemName: "questionmark.circle")
    }
    
    lazy var descriptionLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 20)
        $0.textColor = .darkGray
        $0.textAlignment = .center
        $0.numberOfLines = 0
        $0.text = """
                  오늘 하루는 어떠셨나요 ?
                  오늘 하루가 어땠는지 적어보세요
                  """
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpProperty()
        setUpLayout()
        setUpConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        
    }
}

extension HomeEmptyView: UILayoutable {
    func setUpLayout() {
        addSubview(emptyImageView)
        addSubview(descriptionLabel)
    }
    
    func setUpProperty() {
        
    }
    
    func setUpConstraint() {
        emptyImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.size.equalTo(80)
        }
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(emptyImageView.snp.bottom).offset(10)
            $0.center.equalToSuperview()
        }
    }
}

@available(iOS 17.0, *)
#Preview(traits: .fixedLayout(width: 414, height: 896), body: {
    HomeEmptyView()
})

