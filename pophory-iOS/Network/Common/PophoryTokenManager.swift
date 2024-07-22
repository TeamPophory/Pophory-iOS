//
//  PophoryTokenManager.swift
//  pophory-iOS
//
//  Created by Joon Baek on 2023/07/15.
//

import UIKit

final class PophoryTokenManager {
    static let shared = PophoryTokenManager()
    private init() {}
    
    private let userDefaultsAccessTokenKey = "accessToken"
    private let userDefaultsRefreshTokenKey = "refreshToken"
    private let isLoggedIn = "isLoggedIn"
    
    func saveAccessToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: userDefaultsAccessTokenKey)
    }
    
    func saveRefreshToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: userDefaultsRefreshTokenKey)
    }
    
    func fetchAccessToken() -> String? {
        return UserDefaults.standard.string(forKey: userDefaultsAccessTokenKey)
    }
    
    func fetchRefreshToken() -> String? {
        return UserDefaults.standard.string(forKey: userDefaultsRefreshTokenKey)
    }
    
    func fetchLoggedInState() -> Bool {
        return UserDefaults.standard.bool(forKey: isLoggedIn)
    }
}
