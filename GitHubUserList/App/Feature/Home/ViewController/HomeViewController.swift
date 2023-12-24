//
//  HomeViewController.swift
//  GitHubUserList
//
//  Created by NUNU:D on 12/21/23.
//

import UIKit
import RxSwift
import RxCocoa

final class HomeViewController: UIViewController {

    private lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: compositionalLayout()
    ).then {
        $0.backgroundColor = .white
        $0.keyboardDismissMode = .interactive
        $0.register(
            HomeCollectionViewCell.self,
            forCellWithReuseIdentifier: HomeCollectionViewCell.identifier
        )
    }
    
    private var customSearchBar = CustomSearchBar()
    private let viewModel: HomeViewModel
    private let disposeBag = DisposeBag()
    
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        allSetUp()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if KeychainUtil.read(key: .accessToken) == nil {
            alert(
                title: "",
                message: """
                토큰이 존재하지 않습니다.
                토큰 생성 페이지로 이동하시겠습니까?
                """,
                confirmTitle: "확인",
                confirmHandler: { _ in
                    UIApplication.shared.open(URL(string: "https://github.com/login/oauth/authorize?client_id=Iv1.e45ae2cabb863492")!)
                }
            )
        }
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension HomeViewController: UILayoutable {
    
    func setUpProperty() {
        view.backgroundColor = .white
    }
    
    func setUpLayout() {
        view.addSubview(collectionView)
        view.addSubview(customSearchBar)
    }
    
    func setUpConstraint() {
        
        customSearchBar.snp.makeConstraints {
            $0.left.right.top.equalTo(self.view.safeAreaLayoutGuide)
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(customSearchBar.snp.bottom)
            $0.left.right.equalTo(customSearchBar)
            $0.bottom.equalToSuperview()
        }
    }
    
    func setBind() {
        let output = viewModel.transform()
        
        /// 셀 클릭 시 URL 이동
        collectionView
            .rx
            .modelSelected(User.self)
            .subscribe(onNext: {
                guard let repoURL = $0.htmlURL,
                        let url = URL(string: repoURL) else {
                    return
                }
                
                UIApplication.shared.open(url)
            })
            .disposed(by: disposeBag)
        
        
        /// 페이징 처리
        collectionView
            .rx
            .willDisplayCell
            .flatMap { [weak self] (cell, indexPath) -> Observable<Void> in
                // 셀의 전체 개수를 가져옴
                guard let numberSection = self?.collectionView.numberOfItems(inSection: indexPath.section) else {
                    return .empty()
                }
                
                return (indexPath.row == numberSection - 1) ? .just(()) : .empty()
                
            }
            .bind(to: viewModel.input.actionUserPagingPublish)
            .disposed(by: disposeBag)
        
        customSearchBar
            .shouldLoadResultObservable
            .distinctUntilChanged()
            .bind(to: viewModel.input.actionUserSearchPublish)
            .disposed(by: disposeBag)
        
        
        NotificationCenter.default
            .rx
            .notification(.getAccessToken)
            .subscribe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] noti in
                let token = noti.object as! String
                self?.viewModel.input.actionGetAcccessTokenPublish.accept(token)
            })
            .disposed(by: disposeBag)
    
        output
            .userListPublish
            .bind(
                to: collectionView.rx.items(
                    cellIdentifier: HomeCollectionViewCell.identifier,
                    cellType: HomeCollectionViewCell.self
                )
            ) { row, data, cell in
                
                cell.configure(
                    imageURL: data.avatarURL ?? "",
                    userName: data.login ?? "",
                    gitHubURL: data.htmlURL ?? ""
                )
            }
            .disposed(by: disposeBag)
        
        
        output.showingEmptyViewRelay
            .map { $0 ? EmptyView(message: "검색된 유저가 없습니다") : nil }
            .bind(to: collectionView.rx.backgroundView)
            .disposed(by: disposeBag)
        
        output.errorPublish
            .subscribe(onNext: {[weak self] error in
                // accessToken 발급 도중 에러가 발생했을 경우 종료
                self?.alert(
                    title: "",
                    message: error.errorDescription,
                    confirmTitle: "확인",
                    confirmHandler: { _ in
                        exit(0)
                    }
                )
                
            })
            .disposed(by: disposeBag)
    }
}

extension HomeViewController: UICompositionalable {
    func compositionalLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { section, _ in
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(80)
            )
            
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(80)
            )
            
            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: groupSize,
                subitems: [item]
            )
            
            let section = NSCollectionLayoutSection(group: group)
            
            return section
        }
    }
}

@available(iOS 17.0, *)
#Preview() {
    HomeViewController(
        viewModel: HomeViewModel(
            homeService: HomeService(),
            authService: AuthService()
        )
    )
}
