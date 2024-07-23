//
//  SplashView.swift
//  pophory-iOS
//
//  Created by 강윤서 on 7/23/24.
//

import UIKit

import SnapKit

final class SplashView: UIView {
	private var splashImage: UIImageView = {
		let imageView = UIImageView()
		imageView.image = ImageLiterals.launchIcon
		return imageView
	}()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		setUpStype()
		setUpViews()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

extension SplashView {
	private func setUpStype() {
		self.backgroundColor = .white
	}
	
	private func setUpViews() {
		addSubview(splashImage)
		
		splashImage.snp.makeConstraints {
			$0.center.equalToSuperview()
		}
		
		splashImage.snp.makeConstraints {
			$0.width.equalTo(195)
			$0.height.equalTo(187)
		}
	}
}
