//
//  SceneDelegate.swift
//  ZKFace
//
//  Created by Danna Lee on 2023/05/19.
//

import UIKit

import FirebaseDynamicLinks
import UniformTypeIdentifiers

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    private var errorWindow: UIWindow?
    private var networkMonitor: NetworkMonitor = NetworkMonitor()
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        if let userActivity = connectionOptions.userActivities.first {
            self.scene(scene, continue: userActivity)
        }
        
        startMonitoringNetwork(on: scene)
        setupWindow(for: scene)
    }
    
    func sceneDidDisconnect(_ scene: UIScene) { }
    
    func sceneDidBecomeActive(_ scene: UIScene) { }
    
    func sceneWillResignActive(_ scene: UIScene) { }
    
    func sceneWillEnterForeground(_ scene: UIScene) { }
    
    func sceneDidEnterBackground(_ scene: UIScene) { }
    
    private func isAlbumFull(completion: @escaping (Bool) -> ()) {
        let isLoggedIn = PophoryTokenManager.shared.fetchLoggedInState()
        
        if isLoggedIn {
            var maxPhotoCount: Int?
            var maxPhotoLimit: Int?
            var albumList: FetchAlbumListResponseDTO? {
                didSet {
                    if let albums = albumList?.albums {
                        if albums.count != 0 {
                            maxPhotoCount = albums[0].photoCount
                            maxPhotoLimit = albums[0].photoLimit
                        }
                    }
                }
            }
            
            NetworkService.shared.albumRepository.fetchAlbumList() { result in
                switch result {
                case .success(let response):
                    albumList = response
                    if let maxCount = maxPhotoCount, let maxLimit = maxPhotoLimit {
                        if maxCount >= maxLimit { completion(true) }
                        else { completion(false) }
                    }
                    else { completion(false) }
                default: completion(false)
                }
            }
        }
    }
    
    private func setupAddphotoViewcontroller() {
        var imageType: PhotoCellType = .vertical
        guard let image = UIPasteboard.general.image else { return }
        if image.size.width > image.size.height {
            imageType = .horizontal
        } else {
            imageType = .vertical
        }
        
        RootViewSwitcher.shared.setRootView(.addPhoto(image: image, imageType: imageType))
    }
}

// MARK: network

extension SceneDelegate {
    private func startMonitoringNetwork(on scene: UIScene) {
        networkMonitor.startMonitoring(statusUpdateHandler: { [weak self] connectionStatus in
            switch connectionStatus {
            case .satisfied: self?.removeNetworkErrorWindow()
            case .unsatisfied: self?.loadNetworkErrorWindow(on: scene)
            default: break
            }
        })
    }
    
    private func removeNetworkErrorWindow() {
        DispatchQueue.main.async { [weak self] in
            self?.errorWindow?.resignKey()
            self?.errorWindow?.isHidden = true
            self?.errorWindow = nil
        }
    }
    
    private func loadNetworkErrorWindow(on scene: UIScene) {
        if let windowScene = scene as? UIWindowScene {
            DispatchQueue.main.async { [weak self] in
                let window = UIWindow(windowScene: windowScene)
                window.windowLevel = .statusBar
                window.makeKeyAndVisible()
                let noNetworkView = NoNetworkView(frame: window.bounds)
                window.addSubview(noNetworkView)
                self?.errorWindow = window
            }
        }
    }
}

// MARK: DynamicLink

extension SceneDelegate {
    private func handleDynamicLink(_ dynamicLink: DynamicLink?) -> String? {
        guard let dynamicLink = dynamicLink, let link = dynamicLink.url else { return nil }
        
        if let components = URLComponents(url: link, resolvingAgainstBaseURL: false),
           let queryItems = components.queryItems {
            for item in queryItems {
                if item.name == "u", let value = item.value {
                    return value
                }
            }
        }
        return nil
    }
    
    internal func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        if let url = userActivity.webpageURL {
            _ = DynamicLinks.dynamicLinks().handleUniversalLink(url) { dynamicLink, error in
                if let shareID = self.handleDynamicLink(dynamicLink) {
                    RootViewSwitcher.shared.setRootView(.share(shareId: shareID))
                }
            }
        }
    }
    
    /// 실제 호출되지 않음
//    internal func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
//        guard let url = URLContexts.first?.url else { return }
//        
//        // shareExtension 받았을 때
//        if let range = url.absoluteString.range(of: "//") {
//            let substring = url.absoluteString[range.upperBound...]
//            
//            if substring == "share" {
//                
//                self.isAlbumFull { isAlbumFull in
//                    
//                    let isLoggedIn = PophoryTokenManager.shared.fetchLoggedInState()
//                    
//                    if isLoggedIn {
//                        if isAlbumFull {
//                            RootViewSwitcher.shared.setRootView(.albumFull)
//                        } else {
//                            self.setupAddphotoViewcontroller()
//                        }
//                    } else {
//                        self.setupWindow(for: scene)
//                    }
//                }
//            }
//        }
//    }
}

extension SceneDelegate {
    private func setupWindow(for scene: UIScene) {
        guard let windowScene = scene as? UIWindowScene else { return }
        
        let window = UIWindow(windowScene: windowScene)
        window.overrideUserInterfaceStyle = .light
        RootViewSwitcher.shared.setWindow(window)
        RootViewSwitcher.shared.setupInitialView(PophoryTokenManager.shared.fetchLoggedInState())
        
        self.window = window
    }
}
