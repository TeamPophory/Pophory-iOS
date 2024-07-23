//
//  SplashViewController.swift
//  pophory-iOS
//
//  Created by 강윤서 on 7/23/24.
//

import UIKit

enum UpdateErrorType: Error {
	case verseionFetchError
}

final class SplashViewController: BaseViewController {

	private let splashView = SplashView()
	
	override func viewWillAppear(_ animated: Bool) {
		checkUpdate()
	}
	
	override func setupStyle() {
		super.setupStyle()
		self.view = splashView
		self.navigationController?.isNavigationBarHidden = true
	}
}

// MARK: - Update

extension SplashViewController {
	private func checkUpdate() {
		Task {
			do {
				let isUpdate = try await checkVersion()
				if isUpdate { 
					updatePopUp()
				} else {
					RootViewSwitcher.shared.setupInitialView(PophoryTokenManager.shared.fetchLoggedInState())
				}
			} catch {
				RootViewSwitcher.shared.setupInitialView(PophoryTokenManager.shared.fetchLoggedInState())
			}
		}
	}
	
	private func checkVersion() async throws -> Bool {
		let appVersion = Bundle.appVersion
		guard let minimumVersion = await FirebaseService.shared.fetchRemoteConfig(type: .minimumVersion) else {
			throw UpdateErrorType.verseionFetchError
		}
		
		return appVersion.lexicographicallyPrecedes(minimumVersion)
	}
	
	private func updatePopUp() {
		self.showPopup(image: ImageLiterals.img_albumfull,
					   primaryText: "업데이트가 필요해요",
					   secondaryText: "원활한 이용을 위해\n최신버전으로 업데이트 해주세요.",
					   firstButtonTitle: .confirm,
					   firstButtonHandler: openAppStore)
	}
	
	private func openAppStore() {
		guard let url = URL(string: WebViewURLList.appStore.url) else {
			print("앱스토어 링크를 열 수 없습니다.")
			return
		}
		
		if UIApplication.shared.canOpenURL(url) {
			UIApplication.shared.open(url)
		}
	}
}
