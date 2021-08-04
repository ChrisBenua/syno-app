//
//  VoiceDictionaryNarrationController.swift
//  syno-mobile
//
//  Created by Christian Benua on 24.01.2021.
//  Copyright © 2021 Christian Benua. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class VoiceDictionaryNarrationController: UIViewController {
    private var model: IVoiceNarrationService
    private var views: [VoiceDictionaryNarrationView]
    private var currDictView: VoiceDictionaryNarrationView {
        get {
            return views[model.position()]
        }
    }
    private var speechSynthesizer: AVSpeechSynthesizer!
    private var speechState: SpeechState = .initial
    private var settingsState: SettingsState = .closed
        
    enum SpeechState {
        case initial
        case playing
        case pause
        case done
    }
    
    enum SettingsState {
        case open
        case closed
    }
    
    enum DictSwipe {
        case left
        case right
    }
    
    
    lazy var switchButton: UISwitch = {
        let switch_ = UISwitch()
        switch_.onTintColor = .playButtonColor
        
        return switch_
    }()
    
    lazy var settingsView: UIView = {
        let view = BaseShadowView()
        view.containerViewBackgroundColor = UIColor(red: 240.0/255, green: 240.0/255, blue: 240.0/255, alpha: 1)
        view.cornerRadius = 10
        let label = UILabel()
        label.font = .systemFont(ofSize: 17)
        label.text = "Режим нон-стоп"
        let view1 = UIView()
        view1.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        let sv = UIStackView(arrangedSubviews: [label, view1, switchButton])
        view.addSubview(sv)
        sv.stickToSuperviewEdges(.all, insets: .init(top: 16, left: 16, bottom: 16, right: 16))
        view.alpha = (self.settingsState == .open) ? 1.0 : 0
        
        return view
    }()
    
    private func updateHeaderLabel() {
        self.currDictView.updateHeaderLabel()
    }
    
    
    private func speakCard() {
        if let utterances = model.currSingleVoiceNarrationService.getCurrCardUtterances() {
            Logger.log("Utterances for card \(self.model.currSingleVoiceNarrationService.getCurrCardNumber()): \(utterances.count)")
            utterances.forEach{ speechSynthesizer.speak($0) }
        } else {
            
        }
    }
    
    @objc func handleSwipes(_ sender: UISwipeGestureRecognizer) {
        switch sender.direction {
        case .left:
            dictSwipe(swipe: .left)
        case .right:
            dictSwipe(swipe: .right)
        default:
            break
        }
    }
    
    private func enableOrDisableSwipeGestures(enable: Bool) {
        self.view.gestureRecognizers?.filter({ (gr) -> Bool in
            gr is UISwipeGestureRecognizer
        }).forEach{ $0.isEnabled = enable }
    }
    
    func dictSwipe(swipe: DictSwipe, completion: (() -> Void)? = nil) {
        let currView = self.currDictView
        if swipe == .left && self.model.hasNext() {
            let nextView = self.views[self.model.position() + 1]
            self.view.addSubview(nextView)
            nextView.dictionaryNarrationController = self
            nextView.centerVertically()
            nextView.stickToSuperviewEdges([.left, .right], insets: .init(top: 0, left: 16, bottom: 0, right: 16))
            nextView.transform = .init(translationX: self.view.frame.width, y: 0)
            self.model.goNext()
            enableOrDisableSwipeGestures(enable: false)
            UIView.animate(withDuration: 0.5) {
                currView.transform = .init(translationX: -self.view.frame.width, y: 0)
                nextView.transform = .identity
            } completion: { (_) in
                self.enableOrDisableSwipeGestures(enable: true)
                currView.removeFromSuperview()
                completion?()
            }
            //self.model.currSingleVoiceNarrationService.refresh()
            nextView.refresh()
            self.model.currSingleVoiceNarrationService.delegate = self
            self.flushSpeechSynthesizer()
            self.speechState = .initial
        } else if swipe == .right && self.model.hasPrev() {
            let prevView = self.views[self.model.position() - 1]
            self.view.addSubview(prevView)
            prevView.dictionaryNarrationController = self
            prevView.centerVertically()
            prevView.stickToSuperviewEdges([.left, .right], insets: .init(top: 0, left: 16, bottom: 0, right: 16))
            prevView.transform = .init(translationX: -self.view.frame.width, y: 0)
            self.model.goPrev()
            enableOrDisableSwipeGestures(enable: false)
            UIView.animate(withDuration: 0.5) {
                prevView.transform = .identity
                currView.transform = .init(translationX: self.view.frame.width, y: 0)
            } completion: { (_) in
                self.enableOrDisableSwipeGestures(enable: true)
                currView.removeFromSuperview()
                completion?()
            }
            prevView.refresh()
            //self.model.currSingleVoiceNarrationService.refresh()
            self.model.currSingleVoiceNarrationService.delegate = self
            self.flushSpeechSynthesizer()
            self.speechState = .initial
        }
        
    }
    
    private func flushSpeechSynthesizer() {
        self.speechSynthesizer?.stopSpeaking(at: .immediate)
        self.speechSynthesizer = AVSpeechSynthesizer()
        self.speechSynthesizer.delegate = self.model.currSingleVoiceNarrationService
    }
    
    @objc func playOrPause() {
        if self.speechState == .done {
            self.updateHeaderLabel()
            self.speechState = .initial
            self.model.currSingleVoiceNarrationService.refresh()
            
            self.currDictView.updateHeaderLabel()
        }
        if self.speechState == .pause || self.speechState == .initial {
            UIView.transition(with: self.currDictView.playButtonOver, duration: 0.4, options: .transitionCrossDissolve) {
                self.currDictView.playButtonOver.image = UIImage(systemName: "pause.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 28, weight: .bold))
            }
            
            Logger.log("Speech Synthesizer.isSpeaking ; \(self.speechSynthesizer.isSpeaking)")
            if self.speechSynthesizer.isSpeaking {
                Logger.log("continue speaking")
                self.speechSynthesizer.continueSpeaking()
            } else {
                Logger.log("speaks new card from pause")
                self.speakCard()
            }
            self.speechState = .playing
            
            
        } else {
            UIView.transition(with: self.currDictView.playPauseButton, duration: 0.4, options: .transitionCrossDissolve) {
                UIView.transition(with: self.currDictView.playButtonOver, duration: 0.4, options: .transitionCrossDissolve) {
                    self.currDictView.playButtonOver.image = UIImage(systemName: "play.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 28, weight: .bold))
                }
            }
            
            self.speechState = .pause
            Logger.log("Pausing speech syntesizer")
            flushSpeechSynthesizer()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        let leftSwipeGR = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        leftSwipeGR.direction = .left
        let rightSwipeGR = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        rightSwipeGR.direction = .right
        self.view.addGestureRecognizer(leftSwipeGR)
        self.view.addGestureRecognizer(rightSwipeGR)
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapOnWholeView)))
        
        self.view.addSubview(currDictView)
        self.view.addSubview(settingsView)
        
        currDictView.dictionaryNarrationController = self
        currDictView.centerVertically()
        currDictView.stickToSuperviewEdges([.left, .right], insets: .init(top: 0, left: 16, bottom: 0, right: 16))
        
        settingsView.stickToSuperviewSafeEdges([.left, .right, .top], insets: .init(top: 16, left: 16, bottom: 0, right: 16))
        
        updateHeaderLabel()
        //self.currDictView.dictionaryTitleHeader.text = self.model.currSingleVoiceNarrationService.getDictName()
        self.navigationItem.title = "Режим прослушивания"
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gearshape")!, style: .plain, target: self, action: #selector(onSettingsButtonClick))
    }
    
    @objc func handleTapOnWholeView() {
        if self.settingsState == .open {
            self.settingsState = .closed
            self.animateSettingsView()
        }
    }
    
    @objc func onSettingsButtonClick() {
        if self.settingsState == .closed {
            self.settingsState = .open
        } else {
            self.settingsState = .closed
        }
        
        self.animateSettingsView()
    }
    
    private func animateSettingsView() {
        UIView.animate(withDuration: 0.5) {
            self.settingsView.alpha = (self.settingsState == .open) ? 1.0 : 0
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.speechSynthesizer?.stopSpeaking(at: .immediate)
    }
    
    init(model: IVoiceNarrationService) {
        self.model = model
        self.views = self.model.singleNarrationServices.map({ (singleDictModel) -> VoiceDictionaryNarrationView in
            VoiceDictionaryNarrationView(model: singleDictModel)
        })
        //self.speechSynthesizer = AVSpeechSynthesizer()
        super.init(nibName: nil, bundle: nil)
        flushSpeechSynthesizer()
        self.model.currSingleVoiceNarrationService.delegate = self
        //self.speechSynthesizer.delegate = self.model.currSingleVoiceNarrationService
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        self.speechSynthesizer.stopSpeaking(at: .immediate)
    }
}

extension VoiceDictionaryNarrationController: IVoiceNarrationServiceDelegate {
    func onCompletedCurrCard() {
        updateHeaderLabel()
        if self.model.currSingleVoiceNarrationService.getCurrCardNumber() == self.model.currSingleVoiceNarrationService.getAmountOfCards() {
            if self.switchButton.isOn && self.model.hasNext() {
                self.dictSwipe(swipe: .left) {
                    self.speechState = .done
                    self.flushSpeechSynthesizer()
                    self.playOrPause()
                }
            } else {
                UIView.transition(with: self.currDictView.playButtonOver, duration: 0.4, options: .transitionCrossDissolve) {
                    self.currDictView.playButtonOver.image = UIImage(systemName: "memories", withConfiguration: UIImage.SymbolConfiguration(pointSize: 28, weight: .bold))
                }
                self.speechSynthesizer = AVSpeechSynthesizer()
                self.speechSynthesizer.delegate = self.model.currSingleVoiceNarrationService
                self.speechState = .done
            }
        } else {
            Logger.log("speaks new card on prev card completion")
            self.speakCard()
        }
    }
    
    func onCancelled() {
        //
    }
}

extension VoiceDictionaryNarrationController: IVoiceDictionaryNarrationController {
    
}
