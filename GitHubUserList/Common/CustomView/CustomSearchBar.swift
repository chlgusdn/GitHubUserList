//
//  CustomSearchBar.swift
//  GitHubUserList
//
//  Created by NUNU:D on 12/21/23.
//

import UIKit
import RxSwift
import RxCocoa
import Then
import SnapKit

final class CustomSearchBar: UIView {
    
    private let searchBarContainerStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fill
        $0.spacing = 8
        $0.layer.cornerRadius = 20
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.systemGray5.cgColor
        $0.layoutMargins = UIEdgeInsets(
            top: 10,
            left: 10,
            bottom: 10,
            right: 10
        )
        $0.isLayoutMarginsRelativeArrangement = true
    }
    
    private let searchTextField = UITextField().then {
        $0.text = ""
        $0.placeholder = "유저 검색"
        $0.font = UIFont.systemFont(ofSize: 14)
        $0.textColor = .darkGray
        $0.keyboardType = .webSearch
        $0.returnKeyType = .search
    }
    
    private let clearButton = UIButton().then {
        $0.setImage(
            UIImage(systemName: "xmark.circle"),
            for: .normal
        )
        $0.tintColor = .systemGray4
    }
    
    private let searchButton = UIButton().then {
        $0.tintColor = .systemGray
        $0.setImage(
            UIImage(systemName: "magnifyingglass"),
            for: .normal
        )
    }
    
    private let disposeBag = DisposeBag()
    private let searchButtonTappedPublish = PublishRelay<Void>()
    
    var shouldLoadResultObservable = Observable<String>.of("")
    
    init(placeholder: String = "유저 검색") {
        super.init(frame: .zero)
        searchTextField.placeholder = placeholder
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

extension CustomSearchBar: UILayoutable {
    
    func setUpProperty() {
        searchTextField.rightView = clearButton
        searchTextField.rightViewMode = .whileEditing
    }
    
    func setUpLayout() {
        [searchTextField, searchButton].forEach {
            searchBarContainerStackView.addArrangedSubview($0)
        }
        
        addSubview(searchBarContainerStackView)
    }
    
    func setUpConstraint() {
        searchBarContainerStackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(10)
        }
        
        searchButton.snp.makeConstraints {
            $0.width.equalTo(30)
        }
    }
    
    func setBind() {
        clearButton
            .rx
            .tap
            .asDriver()
            .drive(onNext: { [weak self] in
                self?.searchTextField.text = ""
            })
            .disposed(by: disposeBag)
        
        searchButton
            .rx
            .tap
            .asObservable()
            .bind(to: searchButtonTappedPublish)
            .disposed(by: disposeBag)
        
        searchTextField
            .rx
            .controlEvent(.editingDidEndOnExit)
            .asObservable()
            .bind(to: searchButtonTappedPublish)
            .disposed(by: disposeBag)
        
        shouldLoadResultObservable = searchButtonTappedPublish.withLatestFrom(searchTextField.rx.text) { $1 ?? ""}
    }
}


@available(iOS 17.0, *)
#Preview(
    traits: .fixedLayout(
        width: 414,
        height: 80
    )
) { CustomSearchBar() }
