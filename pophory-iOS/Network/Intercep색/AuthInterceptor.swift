//
//  File.swift
//  pophory-iOS
//
//  Created by 강윤서 on 2/19/24.
//

import Foundation
import Alamofire

final class AuthInterceptor: RequestInterceptor {

	static let shared = AuthInterceptor()

	private init() {}

	func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
		guard let urlString = Bundle.main.infoDictionary?["BASE_URL"] as? String,
			  let url = URL(string: urlString) else {
			fatalError("🚨Base URL을 찾을 수 없습니다🚨")
		}

		guard urlRequest.url?.absoluteString.hasPrefix(urlString) == true,
			  let accessToken = PophoryTokenManager.shared.fetchAccessToken(),
			  let refreshToken = PophoryTokenManager.shared.fetchRefreshToken() else {
			completion(.success(urlRequest))
			return
		}
		
		var urlRequest = urlRequest
		urlRequest.headers.update(name: "Authorization", value: "Bearer \(PophoryTokenManager.shared.fetchAccessToken()!)")
//		urlRequest.setValue("Bearer \(PophoryTokenManager.shared.fetchAccessToken())", forHTTPHeaderField: "Authorization")
		print("🍥🍥🍥adator 적용 \(urlRequest.headers)")
		completion(.success(urlRequest))
	}

	func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
		print("🍥🍥🍥retry 진입")
		guard let response = request.task?.response as? HTTPURLResponse, response.statusCode == 401 else {
			completion(.doNotRetryWithError(error))
			return
		}

		NetworkService.shared.authRepostiory.updateRefreshToken { result in
			switch result {
			case .success(let response):
				guard let data = response as? UpdatedAccessTokenDTO else {
					DispatchQueue.main.async {
						RootViewSwitcher.shared.setRootView(.onboarding)
					}
					completion(.doNotRetryWithError(error))
					return
				}
				PophoryTokenManager.shared.saveAccessToken(data.accessToken)
				PophoryTokenManager.shared.saveRefreshToken(data.refreshToken)
				completion(.retry)
			default:
				DispatchQueue.main.async {
					RootViewSwitcher.shared.setRootView(.onboarding)
				}
				completion(.doNotRetryWithError(error))
			}
		}
	}
}
