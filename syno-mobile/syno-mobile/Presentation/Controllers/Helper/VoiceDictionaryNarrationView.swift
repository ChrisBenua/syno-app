//
//  VoiceDictionaryNarrationView.swift
//  syno-mobile
//
//  Created by Christian Benua on 05.02.2021.
//  Copyright © 2021 Christian Benua. All rights reserved.
//

import Foundation
import UIKit

@objc protocol IVoiceDictionaryNarrationController: AnyObject {
    @objc func playOrPause()
}

class VoiceDictionaryNarrationView: UIView {
    private var model: ISingleVoiceNarrationService
    weak var dictionaryNarrationController: IVoiceDictionaryNarrationController! {
        didSet {
            playPauseButton.addTarget(dictionaryNarrationController, action: #selector(IVoiceDictionaryNarrationController.playOrPause), for: .touchUpInside)
        }
    }
    
    lazy var headerLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17)
        label.textAlignment = .center
        
        return label
    }()
    
    lazy var cardNumberLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17)
        label.textAlignment = .center
        
        return label
    }()
    
    lazy var dictionaryTitleHeader: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        label.textAlignment = .center
        
        return label
    }()
    
    lazy var playButtonOver: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "play.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 28, weight: .semibold)))
        iv.tintColor = .white
        
        return iv
    }()
    
    lazy var containerView: BaseShadowView = {
        let view = BaseShadowView()
        view.containerViewBackgroundColor = UIColor(red: 240.0/255, green: 240.0/255, blue: 240.0/255, alpha: 1)
        view.cornerRadius = 10
        
        let stackView = UIStackView(arrangedSubviews: [dictionaryTitleHeader, headerStackView, playPauseButton])
        stackView.axis = .vertical
        stackView.setCustomSpacing(8, after: dictionaryTitleHeader)
        stackView.setCustomSpacing(16, after: headerStackView)
        view.containerView.addSubview(stackView)
        
        stackView.stickToSuperviewEdges(.all, insets: .init(top: 16, left: 16, bottom: 16, right: 16))
        if #available(iOS 13.0, *) {
            playPauseButton.addSubview(playButtonOver)
            playButtonOver.centerVertically()
            playButtonOver.centerHorizontally(0, to: playPauseButton)
        }
        
        return view
    }()
    
    lazy var headerStackView: UIStackView = {
        let view1 = UIView(); let view2 = UIView(); view1.setContentHuggingPriority(.defaultLow, for: .horizontal); view2.setContentHuggingPriority(.defaultLow, for: .horizontal)
        let sv = UIStackView(arrangedSubviews: [view1, cardNumberLabel, headerLabel, view2])
        view1.width(to: view2)
        sv.axis = .horizontal
        
        return sv
    }()
    
    lazy var playPauseButton: UIButton = {
        let config = CustomUIButtonConfigurationBuilder()
            .setBackgroundColor(UIColor.playButtonColor.cgColor)
            .setPressedBackgroundColor(#colorLiteral(red: 0.4084591479, green: 0.5312166919, blue: 0.6908872378, alpha: 1))
            .setBasicShadowRadius(0)
            .setPressedShadowRadius(0)
            .setCornerRadius(10)
            .build()
        let button = CustomUIButton()
        button.setConfiguration(configuration: config)
        
        button.setAttributedTitle(NSAttributedString(string: " ", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 24, weight: .bold)]), for: .normal)
        button.tintColor = .black
        
        button.contentEdgeInsets = .init(top: 9, left: 0, bottom: 9, right: 0)
        //button.addTarget(self, action: #selector(playOrPause), for: .touchUpInside)
        
        return button
    }()
    
    init(model: ISingleVoiceNarrationService) {
        self.model = model
        super.init(frame: .zero)
        self.layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateHeaderLabel() {
        self.headerLabel.text = " карточка из \(self.model.getAmountOfCards())"
        UIView.transition(with: self.cardNumberLabel, duration: 0.5, options: .transitionCrossDissolve) {
            self.cardNumberLabel.text = "\(min(self.model.getCurrCardNumber() + 1, self.model.getAmountOfCards()))"
        }
        self.dictionaryTitleHeader.text = self.model.getDictName()
    }
    
    func refresh() {
        self.model.refresh()
        self.updateHeaderLabel()
        self.playButtonOver.image = UIImage(systemName: "play.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 28, weight: .semibold))
    }
    
    private func layout() {
        self.addSubview(containerView)
        //containerView.centerVertically()
        containerView.stickToSuperviewEdges(.all, insets: .init(top: 0, left: 0, bottom: 0, right: 0))
        
        self.updateHeaderLabel()
    }
}
