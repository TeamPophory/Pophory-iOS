//
//  RootViewSwitcher.swift
//  pophory-iOS
//
//  Created by 강윤서 on 7/21/24.
//

import UIKit

enum RootView {
	case splash
    case onboarding
    case home
    case albumFull
    case addPhoto(image: UIImage, imageType: PhotoCellType)
    case share(shareId: String)
}

enum UpdateType {
	case force
	case optional
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
		case .splash:
			rootViewController = SplashViewController()
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
        case .share(let shareId):
            rootViewController = ShareViewController()
            if let vc = rootViewController as? ShareViewController {
                vc.setupShareID(forShareID: shareId)
            }
        case .addPhoto(let image, let imageType):
            let tabBarController = TabBarController()
            let addPhotoViewController = AddPhotoViewController()
            addPhotoViewController.setupRootViewImage(forImage: image, forType: imageType)
            
            let navigationController = PophoryNavigationController(rootViewController: tabBarController)
            navigationController.pushViewController(addPhotoViewController, animated: false)
            return
		}
        window.rootViewController = PophoryNavigationController(rootViewController: rootViewController)
        window.makeKeyAndVisible()
    }
}
