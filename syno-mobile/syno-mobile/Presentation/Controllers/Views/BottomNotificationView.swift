//
//  BottomNotificationView.swift
//  syno-mobile
//
//  Created by Ирина Улитина on 10.04.2020.
//  Copyright © 2020 Christian Benua. All rights reserved.
//

import Foundation
import UIKit

protocol IBottomNotificationViewDelegate: class {
    func onCancelButtonPressed()
    
    func onTimerDone()
}

class BottomNotificationView: UIView {
    
    weak var delegate: IBottomNotificationViewDelegate?
    
    private var timer: Timer?
    
    var timeout: TimeInterval = 5.0
    
    private var timeLeft: TimeInterval!
    
    lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17)
        label.textColor = .white
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        return label
    }()
    
    lazy var timerLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22)
        label.textColor = .white
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        label.textAlignment = .center
        
        
        return label
    }()
    
    lazy var cancelButtonLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22)
        label.textColor = #colorLiteral(red: 0, green: 0.4793452024, blue: 0.9990863204, alpha: 1)
        label.isUserInteractionEnabled = true
        let reco = UITapGestureRecognizer(target: self, action: #selector(onCancelButtonTapped))
        
        label.addGestureRecognizer(reco)
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        return label
    }()
    
    @objc func onCancelButtonTapped() {
        print("cancel!")
        timer?.invalidate()
        
        UIView.transition(with: cancelButtonLabel, duration: 0.2, options: .transitionCrossDissolve, animations: {
            self.cancelButtonLabel.textColor = .white
        })
        
        delegate?.onCancelButtonPressed()
        UIView.animate(withDuration: 1, animations: {
            self.alpha = 0
        }) { (_) in
            self.removeFromSuperview()
        }
    }
    
    func initTimer() {
        timer?.invalidate()
        timeLeft = self.timeout
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { (tm) in
            DispatchQueue.main.async {
                if (abs(self.timeLeft - 1) < 1e-9) {
                    tm.invalidate()
                    self.delegate?.onTimerDone()
                    UIView.animate(withDuration: 1, animations: {
                               self.alpha = 0
                           }) { (_) in
                               self.removeFromSuperview()
                           }
                } else {
                    self.timeLeft -= 1
                    self.timerLabel.text = "\(Int(round(self.timeLeft)))"
                }
            }
        })
    }

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.clipsToBounds = true
        self.layer.cornerRadius = 10
        self.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        
        self.addSubview(timerLabel)
        self.addSubview(messageLabel)
        self.addSubview(cancelButtonLabel)
        
        self.timerLabel.anchor(top: self.topAnchor, left: self.leftAnchor, bottom: self.bottomAnchor, right: nil, paddingTop: 5, paddingLeft: 10, paddingBottom: 5, paddingRight: 0, width: 0, height: 0)
        self.messageLabel.anchor(top: nil, left: self.timerLabel.rightAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        self.messageLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        self.cancelButtonLabel.anchor(top: nil, left: self.messageLabel.rightAnchor, bottom: nil, right: self.rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 10, width: 0, height: 0)
        self.cancelButtonLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        initTimer()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension BottomNotificationView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
