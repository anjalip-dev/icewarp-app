//
//  PrefManager.swift
//  ice_warp
//
//  Created by Anjali Pandey on 07/12/24.
//

import Foundation

public class PrefManager {
    
    // initialization
    
    public static let shared = PrefManager()
    private init() {}
    
    // methods
    
    func setPreference(_ key: String, value: AnyObject) {
        UserDefaults.standard.setValue(value, forKey: key)
    }
    
    func getPreference(_ key: String) -> AnyObject {
        return UserDefaults.standard.value(forKey: key) as AnyObject
    }
    
    func setAuthorizationToken(_ token: String) {
        setPreference("authorizationToken", value: token as AnyObject)
    }
    
    func getAuthorizationToken() -> String? {
        return getPreference("authorizationToken") as? String
    }
    
    func clearData()
    {
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
    }
    
}
