//
//  SceneDelegate.swift
//  GitHubUserList
//
//  Created by NUNU:D on 12/21/23.
//

import UIKit
import Moya

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        self.window = UIWindow(windowScene: windowScene)
        self.window?.overrideUserInterfaceStyle = .light
        let homeService = HomeService()
        let authService = AuthService()
        let homeViewModel = HomeViewModel(
            homeService: homeService,
            authService: authService
        )
        let homeViewController = HomeViewController(viewModel: homeViewModel)
        self.window?.rootViewController = homeViewController
        self.window?.makeKeyAndVisible()
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = URLContexts.first?.url {
            let code = url.absoluteString.components(separatedBy: "code=").last ?? ""
            NotificationCenter.default.post(name: .getAccessToken, object: code)
        }
    }
}

