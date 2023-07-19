//
//  ShareAPI.swift
//  pophory-iOS
//
//  Created by 김다예 on 2023/07/20.
//

import Foundation

import Moya

enum ShareAPI {
    case patchSharePhoto
    case postSharePhoto(body: PostSharePhotoRequestDTO)
}

extension ShareAPI: BaseTargetType {
    
    var authToken: String? {
        return PophoryTokenManager.shared.fetchAccessToken()
    }
    
    var path: String {
        switch self {
        case .patchSharePhoto:
            return URLConstantsV2.share
        case .postSharePhoto:
            return URLConstantsV2.share + "/photo"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .patchSharePhoto:
            return .get
        case .postSharePhoto:
            return .post
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .patchSharePhoto, .postSharePhoto:
            return .requestPlain
        }
    }
}