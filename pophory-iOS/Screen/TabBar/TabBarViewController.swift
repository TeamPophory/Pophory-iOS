//
//  TabBarViewController.swift
//  ZKFace
//
//  Created by Joon Baek on 2023/06/27.
//

import UIKit

import Photos
import SnapKit

final class TabBarController: UITabBarController, PHPickerProtocol {
    
    // MARK: - Properties
    
    private var isAlbumFull: Bool = false
    
    // MARK: - ViewController properties
    
    private let homeAlbumViewController = HomeAlbumViewController()
    private let plusViewController = UIViewController()
    private let myPageViewController = MypageViewController()
    
    private let addPhotoViewController = AddPhotoViewController()
    internal var imagePHPViewController = BasePHPickerViewController()
    internal let limitedViewController = PHPickerLimitedPhotoViewController()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupShareNetworkRequest()
        setupTabBar()
        setupDelegate()
        
//        #if RELEASE
//        guard let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else { return }
//        fetchAdInfo(os: "ios", version: version)
//        #endif
    }
}

// MARK: - Extensions

extension TabBarController {
    
    // MARK: - Setups
    
    private func setupShareNetworkRequest() {
        ShareNetworkManager.shared.requestPostSharePhoto() { [weak self] response in
            if (response?.albumId == 4423) {
                self?.showPopup(popupType: .simple,
                                secondaryText: "이미 내 앨범에 있는 사진이에요",
                                firstButtonTitle: .back)
            }
            self?.homeAlbumViewController.requestGetAlumListAPI()
        }
    }
    
    private func setupTabBar(){
        self.tabBar.tintColor = .pophoryPurple
        self.tabBar.unselectedItemTintColor = .pophoryGray400
        self.tabBar.isTranslucent = false
        self.tabBar.backgroundColor = .pophoryWhite
        
        let imageInset: CGFloat = UIScreen.main.hasNotch ? 10 : 0
        homeAlbumViewController.tabBarItem.imageInsets = UIEdgeInsets(top: imageInset, left: 0, bottom: -imageInset, right: 0)
        plusViewController.tabBarItem.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        myPageViewController.tabBarItem.imageInsets = UIEdgeInsets(top: imageInset, left: 0, bottom: -imageInset, right: 0)
        
        let viewControllers:[UIViewController] = [
            homeAlbumViewController,
            plusViewController,
            myPageViewController
        ]
        self.setViewControllers(viewControllers, animated: true)
        
        homeAlbumViewController.tabBarItem.image = ImageLiterals.tabBarHomeAlbumIcon
        plusViewController.tabBarItem.image = ImageLiterals.tabBarEditAlbumIcon
        myPageViewController.tabBarItem.image = ImageLiterals.tabBarMyPageIcon
        
        self.hidesBottomBarWhenPushed = false
        viewWillLayoutSubviews()
    }
    
    private func setupDelegate() {
        self.delegate = self
        homeAlbumViewController.albumStatusDelegate = self
        imagePHPViewController.delegate = self
    }
}

// MARK: - UITabBarControllerDelegate

extension TabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController == plusViewController {
            if isAlbumFull == true {
                showPopup(
                    image: ImageLiterals.img_albumfull,
                    primaryText: "포포리 앨범이 가득찼어요",
                    secondaryText: "아쉽지만,\n다음 업데이트에서 만나요!"
                )
                return  false
            }
            
            imagePHPViewController.setupImagePermission()
            return false
        } else {
            return true
        }
    }
}

extension TabBarController: AlbumStatusProtocol {
    func isAblumFull(isFull: Bool) {
        self.isAlbumFull = isFull
    }
}
