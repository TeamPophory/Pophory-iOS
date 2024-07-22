//
//  Config.swift
//  pophory-iOS
//
//  Created by 강윤서 on 7/21/24.
//

import Foundation

enum Config: String {
    case baseURL = "BASE_URL"
    case sentryDNS = "SENTRY_DSN"
    case unitADId = "UNIT_AD_ID"
}

extension Bundle {
    static var plist: [String: Any]? {
        guard let url = Bundle.main.url(forResource: "Info", withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any] else {
            fatalError("Could't load 'Info.plist'.")
        }
        return plist
    }
    
    private static func getString(forKey key: String) -> String {
        guard let value = plist?[key] as? String else {
            fatalError("Could't find key \(key) in 'Info.plist'.")
        }
        return value
    }
    
    static var identifier: String {
        guard let identifier = Bundle.main.bundleIdentifier else {
            fatalError("Could't find bundleIdentifier")
        }
        return identifier
    }
    
    static var baseURL: String {
        return getString(forKey: Config.baseURL.rawValue)
    }
    
    static var sentryDNS: String {
        return getString(forKey: Config.sentryDNS.rawValue)
    }
    
    static var unitAdID: String {
        return getString(forKey: Config.unitADId.rawValue)
    }
}
