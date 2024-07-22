//
//  OnboardingViewController.swift
//  ZKFace
//
//  Created by Joon Baek on 2023/06/27.
//

import AuthenticationServices

import UIKit

final class OnboardingViewController: BaseViewController {
    
    // MARK: - Properties
    
    lazy var onboardingView = OnboardingView()
    
    private let appleLoginManager: AppleLoginManager
    
    // MARK: - Life Cycle
    
    init(appleLoginManager: AppleLoginManager) {
        self.appleLoginManager = appleLoginManager
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        PophoryNavigationConfigurator.shared.configureNavigationBar(in: self)
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        hideNavigationBar()
        setupAppleSignInButton()
    }
    
    override func viewDidLayoutSubviews() {
        view.addSubview(onboardingView)
        
        onboardingView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaInsets)
        }
    }
    
}

// MARK: - Extensions

extension OnboardingViewController {
    
    // MARK: - @objc
    
    @objc private func handleAppleLoginButtonClicked() {
        appleLoginManager.setAppleLoginPresentationAnchorView(self)
        appleLoginManager.handleAppleLoginButtonClicked()
    }
    
    // MARK: - Private Methods
    
    private func setupAppleSignInButton() {
        onboardingView.realAppleSignInButton.addTarget(self, action: #selector(handleAppleLoginButtonClicked), for: .touchUpInside)
    }
    
    private func goToSignInViewController() {
        let nameInputVC = NameInputViewController()
        navigationController?.pushViewController(nameInputVC, animated: true)
    }
    
    private func navigateToTabBarController() {
       RootViewSwitcher.shared.setRootView(.home)
    }
}

// MARK: - Network

extension OnboardingViewController: AppleLoginManagerDelegate {
    
    func appleLoginManager(didCompleteWithAuthResult result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                if let identityTokenData = appleIDCredential.identityToken,
                   let identityTokenString = String(data: identityTokenData, encoding: .utf8) {
                    print("Identity Token: \(identityTokenString)")
                    submitIdentityTokenToServer(identityToken: identityTokenString)
                }
                
                print("Successful Apple login")
            }
            
        case .failure(let error):
            print("Failed Apple login with error: \(error.localizedDescription)")
        }
    }
   
   private func submitIdentityTokenToServer(identityToken: String) {
      let tokenDTO = PostIdentityTokenDTO(socialType: "APPLE", identityToken: identityToken)
      NetworkService.shared.authRepostiory.submitIdentityToken(tokenDTO: tokenDTO) { result in
         DispatchQueue.main.async {
            switch result {
            case .success(let response):
               if let loginResponse = response as? PostLoginAPIDTO {
                  print("Successfully sent Identity Token to server")
                  
                  PophoryTokenManager.shared.saveAccessToken(loginResponse.accessToken)
                  PophoryTokenManager.shared.saveRefreshToken(loginResponse.refreshToken)
                  
                  UserDefaults.standard.set(true, forKey: "isLoggedIn")
                  
                  self.decideNextVC(isRegistered: loginResponse.isRegistered)
                  
               } else {
                  print("Unexpected response")
               }
            case .requestErr(let message):
               print("Error sending Identity Token to server: \(message)")
            case .networkFail:
               self.presentErrorViewController(with: .networkError)
            case .serverErr, .pathErr:
               self.presentErrorViewController(with: .serverError)
            default:
               break
            }
         }
      }
   }
    
    private func decideNextVC(isRegistered: Bool) {
        if isRegistered {
            navigateToTabBarController()
        } else {
            goToSignInViewController()
        }
    }
}
