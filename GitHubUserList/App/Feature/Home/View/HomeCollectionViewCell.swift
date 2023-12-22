//
//  HomeCollectionViewCell.swift
//  GitHubUserList
//
//  Created by NUNU:D on 12/21/23.
//

import UIKit
import Kingfisher

final class HomeCollectionViewCell: UICollectionViewCell, Identifierable {
    
    private let userImageView = UIImageView().then {
        $0.layer.cornerRadius = 25
        $0.layer.masksToBounds = true
        $0.backgroundColor = .red
    }
    
    private let userNameLabel = UILabel().then {
        $0.text = "chlgusdn"
        $0.textColor = .darkGray
        $0.font = UIFont.systemFont(ofSize: 16)
    }
    
    private let githubURLAddressLabel = UILabel().then {
        $0.text = "https://"
        $0.textColor = .darkGray
        $0.font = UIFont.systemFont(ofSize: 14)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        allSetUp()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension HomeCollectionViewCell {
    func configure(imageURL: String, userName: String, gitHubURL: String) {
        userImageView.kf.setImage(with: URL(string: imageURL)!)
        userNameLabel.text = userName
        githubURLAddressLabel.text = gitHubURL
    }
}

extension HomeCollectionViewCell: UILayoutable {
    func setUpLayout() {
        [userImageView, userNameLabel, githubURLAddressLabel].forEach {
            addSubview($0)
        }
    }
    
    func setUpConstraint() {
        userImageView.snp.makeConstraints {
            $0.size.equalTo(50)
            $0.left.equalToSuperview().offset(10)
            $0.centerY.equalToSuperview()
        }
        
        userNameLabel.snp.makeConstraints {
            $0.left.equalTo(userImageView.snp.right).offset(10)
            $0.right.equalToSuperview().inset(10)
            $0.top.equalTo(userImageView).offset(4)
        }
        
        githubURLAddressLabel.snp.makeConstraints {
            $0.left.right.equalTo(userNameLabel)
            $0.top.equalTo(userNameLabel.snp.bottom).offset(4)
        }
    }
}

@available(iOS 17.0, *)
#Preview(
    traits: .fixedLayout(
        width: 414,
        height: 80
    )
) { HomeCollectionViewCell() }
