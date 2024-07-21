//
//  RootViewSwitcher.swift
//  pophory-iOS
//
//  Created by 강윤서 on 7/21/24.
//

import UIKit

enum RootView {
    case onboarding
    case home
    case albumFull
}

final class RootViewSwitcher {
    
    static let shared = RootViewSwitcher()
    
    private var window: UIWindow?
    
    private init() { }
    
    func setWindow(_ window: UIWindow) {
        self.window = window
    }
    
    func setupInitialView(_ isLoggedIn: Bool) {
        isLoggedIn ? setRootView(.home) : setRootView(.onboarding)
    }
}

extension RootViewSwitcher {
    func setRootView(_ rootView: RootView) {
        guard let window = self.window else { return }
        
        var rootViewController: UIViewController
        switch rootView {
        case .onboarding:
            let appleLoginManager = AppleLoginManager()
            let onboardingViewController = OnboardingViewController(appleLoginManager: appleLoginManager)
            appleLoginManager.delegate = onboardingViewController
            rootViewController = onboardingViewController
        case .home:
            rootViewController = TabBarController()
        case .albumFull:
            rootViewController = TabBarController()
            rootViewController.showPopup(popupType: .simple,
                                         image: ImageLiterals.img_albumfull,
                                         primaryText: "포포리 앨범이 가득찼어요",
                                         secondaryText: "아쉽지만,\n다음 업데이트에서 만나요!")
        }
        window.rootViewController = PophoryNavigationController(rootViewController: rootViewController)
    }
}
