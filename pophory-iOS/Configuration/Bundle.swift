//
//  Config.swift
//  pophory-iOS
//
//  Created by 강윤서 on 7/21/24.
//

import Foundation

extension Bundle {
    static var plist: NSDictionary? {
        guard let filePath = Bundle.main.url(forResource: "Info", withExtension: "plist") else {
            fatalError("Could't find file 'Info.plist'.")
        }
        guard let plist = NSDictionary(contentsOf: filePath) else {
            return nil
        }
        return plist
    }
    
    private static func getString(_ forKey: String) -> String {
        guard let value = Bundle.plist?.object(forKey: forKey) as? String else {
            fatalError("Could't find key \(forKey) in 'Info.plist'.")
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
        return getString("BASE_URL")
    }
    
    static var sentryDNS: String {
        return getString("SENTRY_DNS")
    }
    
    static var unitAdID: String {
        return getString("UNIT_AD_ID")
    }
    
    static var GADApplicationIdentifier: String {
        return getString("GADApplicationIdentifier")
    }
}
