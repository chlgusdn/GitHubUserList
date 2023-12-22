//
//  UIApplication+.swift
//  GitHubUserList
//
//  Created by NUNU:D on 12/22/23.
//

import UIKit

/// UIApplication에서 사용될 각종 extension
extension UIApplication {
    var sceneDelegate: SceneDelegate {
        guard let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate else {
            fatalError("sceneDelegate가 존재하지 않습니다")
        }
        return sceneDelegate
    }
}
