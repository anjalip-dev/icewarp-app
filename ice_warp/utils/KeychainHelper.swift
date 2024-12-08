//
//  KeychainHelper.swift
//  ice_warp
//
//  Created by Anjali Pandey on 08/12/24.
//

import Foundation
import Security

public class KeyChainHelper {
    
    // initialization
    
    public static let shared = KeyChainHelper()
    private init() {}
 
    func saveDataToKeychain(key: String, _ token: String) {
        
        let tokenData = Data(token.utf8)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: tokenData
        ]
        
        // Remove existing tokne if it exists
        SecItemDelete(query as CFDictionary)
        
        // Add new token
        let status = SecItemAdd(query as CFDictionary, nil)
        if status == errSecSuccess {
            print("Token saved to Keychain successfully.")
        } else {
            print("Failed to save token: \(status)")
        }
        
    }

    func getDataFromKeychain(key: String) -> String? {
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        if status == errSecSuccess, let tokenData = item as? Data {
            return String(data: tokenData, encoding: .utf8)
        } else {
            print("Failed to retrieve token: \(status)")
            return nil
        }
        
    }
    
    func clearAllKeychainData() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        if status == errSecSuccess {
            print("All data cleared from Keychain.")
        } else if status == errSecItemNotFound {
            print("No data found to delete.")
        } else {
            print("Failed to clear Keychain data: \(status)")
        }
    }

    
}
