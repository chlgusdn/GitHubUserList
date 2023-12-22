//
//  UIViewController+.swift
//  GitHubUserList
//
//  Created by NUNU:D on 12/22/23.
//

import UIKit

/// UIViewController에서 사용될 각종 extension
extension UIViewController {
    /// UIAlertController를 보다 편리하게 사용하기 위한 유틸 함수
    func alert(title:String? = nil, message: String? = nil, confirmTitle: String? = nil, cancelTitle: String? = nil, confirmHandler: ((UIAlertAction) -> Void)? = nil, cancelHandler: ((UIAlertAction) -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if let confirmTitle = confirmTitle {
            alertController.addAction(UIAlertAction(title: confirmTitle, style: .default, handler: confirmHandler))
        }
        
        if let cancelTitle = cancelTitle {
            alertController.addAction(UIAlertAction(title: cancelTitle, style: .default, handler: cancelHandler))
        }
        
        UIApplication.shared.sceneDelegate.window?.rootViewController?.present(alertController, animated: true)
    }
}
