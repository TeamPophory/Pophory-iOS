//
//  FirebaseService.swift
//  pophory-iOS
//
//  Created by 강윤서 on 7/22/24.
//

import Firebase
import FirebaseRemoteConfig

final class FirebaseService {
    static let shared = FirebaseService()
    
    private let config = RemoteConfig.remoteConfig()
    
    enum RemoteConfigType: String {
        case minimumVersion = "minimum_update_version_iOS"
    }
    
    private init() {
        self.setRemoteConfigSetting()
    }
}

extension FirebaseService {
    private func setRemoteConfigSetting() {
        let setting = RemoteConfigSettings()
        setting.minimumFetchInterval = 0
        setting.fetchTimeout = 1
        config.configSettings = setting
    }
    
    func fetchRemoteConfig(type: RemoteConfigType) async -> String? {
        return await withCheckedContinuation { continuation in
            config.fetch { status, error in
                if status == .success {
                    self.config.activate { change, error in
                        guard let version = self.config[type.rawValue].stringValue,
                                !version.isEmpty else {
                            continuation.resume(returning: nil)
                            return
                        }
                        continuation.resume(returning: version)
                    }
                } else {
                    continuation.resume(returning: nil)
                }
            }
        }
    }
}
