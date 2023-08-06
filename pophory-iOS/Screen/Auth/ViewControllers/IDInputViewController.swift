//
//  IDInputViewController.swift
//  pophory-iOS
//
//  Created by Joon Baek on 2023/07/01.
//

import UIKit

import SnapKit

final class IDInputViewController: BaseViewController {
    
    // MARK: - Properties
    
    private let networkManager: AuthNetworkManager
    
    var fullName: String?
    
    var onNicknameEntered: ((String, String) -> Void)?
    
    // MARK: - UI Properties
    
    private let iDInputView = IDInputView()
    
    // MARK: - Life Cycle
    
    init(fullName: String, networkManager: AuthNetworkManager = AuthNetworkManager()) {
        self.fullName = fullName
        self.networkManager = networkManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupNavigationBar(with: PophoryNavigationConfigurator.shared)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        handleNextButton()
        hideKeyboard()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        setupViewConstraints(iDInputView)
    }
}

// MARK: - Extensions

extension IDInputViewController: Navigatable {
    var navigationBarTitleText: String? { "회원가입" }
}

extension IDInputViewController {
    
    // MARK: - @objc
    
    private func nextButtonOnTouchUpInsideAsync() async {
        guard let nickname = iDInputView.inputTextField.text, !nickname.trimmingCharacters(in: .whitespaces).isEmpty, let fullName = self.fullName else { return }
        await checkNicknameAndProceed(nickname: nickname, fullName: fullName)
    }
    
    // MARK: - Private Functions
    
    private func goToPickAlbumCoverViewController(with nickname: String, fullName: String) {
        createUserProfile(nickname: nickname, fullName: fullName)
        dismissKeyboard()
        presentPickAlbumCoverViewController(with: nickname, fullName: fullName)
    }
    
    private func createUserProfile(nickname: String, fullName: String) {
        UserDefaults.standard.setNickname(nickname)
        UserDefaults.standard.setFullName(fullName)
    }
    
    private func presentPickAlbumCoverViewController(with nickname: String, fullName: String) {
        let pickAlbumCoverVC = PickAlbumCoverViewController(fullName: fullName, nickname: nickname)
        
        pickAlbumCoverVC.fullName = fullName
        pickAlbumCoverVC.nickname = nickname
        
        navigationController?.pushViewController(pickAlbumCoverVC, animated: true)
    }
    
    private func handleNextButton() {
        let nextButtonAction = UIAction { [weak self] _ in
            guard let self = self else { return }
            Task {
                await self.nextButtonOnTouchUpInsideAsync()
            }
        }
        iDInputView.nextButton.addAction(nextButtonAction, for: .touchUpInside)
    }
}

// MARK: - Network

extension IDInputViewController {
    func checkNicknameAndProceed(nickname: String, fullName: String) async {
        do {
            let isDuplicated = try await networkManager.requestNicknameCheck(nickname: nickname)

            if isDuplicated {
                self.showPopup(popupType: .simple, secondaryText: "이미 있는 아이디예요.\n다른 아이디를 입력해 주세요!")
            } else {
                self.goToPickAlbumCoverViewController(with: nickname, fullName: fullName)
            }
        } catch {
            self.presentErrorViewController(with: .serverError)
        }
    }
}
