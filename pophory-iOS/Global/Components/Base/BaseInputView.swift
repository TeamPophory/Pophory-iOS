//
//  BaseInputView.swift
//  pophory-iOS
//
//  Created by Joon Baek on 2023/07/03.
//

import UIKit
import SnapKit

class BaseSignUpView: UIView {
    
    lazy var headerLabel: UILabel = {
        let label = UILabel()
        label.text = "만나서 반가워\n너의 이름이 궁금해!"
        label.textColor = .black
        label.font = .h1
        label.numberOfLines = 0
        label.asColor(targetString: "너의 이름", color: .pophoryPurple)
        return label
    }()
    
    lazy var nextButton: PophoryButton = {
        let buttonBuilder = PophoryButtonBuilder()
            .setStyle(.primary)
            .setTitle(.next)
        return buttonBuilder.build()
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Extensions

extension BaseSignUpView {
    
    // MARK: - Layout
    
    private func setupViews() {
        
        addSubviews([headerLabel, nextButton])
        
        headerLabel.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).offset(32)
            $0.leading.equalToSuperview().offset(20)
        }
        
        nextButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(36)
        }
        
        nextButton.addCenterXConstraint(to: self)
    }
    
    // MARK: - @objc
    
    // MARK: - Private Methods
    
}