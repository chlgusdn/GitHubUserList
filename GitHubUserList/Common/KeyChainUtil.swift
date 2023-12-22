//
//  KeyChainUtil.swift
//  GitHubUserList
//
//  Created by NUNU:D on 12/22/23.
//

import Foundation

///Keychain CRUD 유틸클래스
final class KeychainUtil {
    
    static let service = Bundle.main.bundleIdentifier!
    
    enum Keys: String {
        case accessToken
        case refreshToken
    }
    
    @discardableResult
    static func create(key: Keys, token: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key.rawValue,
            kSecValueData as String: token.data(using: .utf8) as Any
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        guard status == errSecSuccess else {
            print("Keychain Create Error \n [Message]: \(String(describing: SecCopyErrorMessageString(status, nil)))")
            return false
        }
        
        return true
    }
    
    @discardableResult
    static func read(key: Keys) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key.rawValue,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnData as String: true,
            kSecReturnAttributes as String: true
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        guard status != errSecItemNotFound else {
            print("KeyChain item Not Fount \n [Message]: \(String(describing: SecCopyErrorMessageString(status, nil)))")
            return nil
        }
        
        guard status == errSecSuccess else {
            print("KeyChain item read Error \n [Message]: \(String(describing: SecCopyErrorMessageString(status, nil)))")
            return nil
        }
        
        guard let existingItem = item as? [String: Any],
              let tokenData = existingItem[kSecValueData as String] as? Data,
              let token = String(data: tokenData, encoding: .utf8) else {
            print("Keychain get token Faild \n [Message]: \(String(describing: SecCopyErrorMessageString(status, nil)))")
            return nil
        }
        
        return token
    }
    
    @discardableResult
    static func update(key: Keys, token: String) -> Bool {
        let query: [String: Any] = [
            kSecAttrService as String: service,
            kSecAttrAccount as String: key.rawValue,
            kSecClass as String: kSecClassGenericPassword,
        ]
        
        let attributes: [String: Any] = [
            kSecValueData as String: token.data(using: .utf8) as AnyObject
        ]
        
        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        guard status != errSecDuplicateItem else {
            print("Keychain errSecDuplicate Item \n [Message]: \(String(describing: SecCopyErrorMessageString(status, nil)))")
            return false
        }
        guard status == errSecSuccess else {
            print("Keychain update Error \n [Message]: \(String(describing: SecCopyErrorMessageString(status, nil)))")
            return false
        }
        
        return true
    }
    
    @discardableResult
    static func delete(key: Keys) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key.rawValue
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess ||
              status == errSecItemNotFound else {
            print("Keychain delete Error \n [Message]: \(String(describing: SecCopyErrorMessageString(status, nil)))")
            return false
        }
        
        return true
    }
}
