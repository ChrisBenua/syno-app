//
//  LearnController.swift
//  syno-mobile
//
//  Created by Ирина Улитина on 20.12.2019.
//  Copyright © 2019 Christian Benua. All rights reserved.
//

import Foundation
import UIKit

protocol ILearnViewControllerData {
    var cardsAmount: Int { get }
    var dictName: String? { get }
}

class LearnViewControllerData: ILearnViewControllerData {
    var cardsAmount: Int
    
    var dictName: String?
    
    init(cardsAmount: Int, dictName: String?) {
        self.cardsAmount = cardsAmount
        self.dictName = dictName
    }
}

class LearnCollectionViewController: UIViewController {
    
    private var data: ILearnViewControllerData
    
    private var learnViews: [ILearnView]
    
    private var currCardNumber: Int = 0
        
    var contentView: ILearnView {
        get {
            return learnViews[currCardNumber]
        }
    }
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        scrollView.alwaysBounceHorizontal = false
        scrollView.delegate = self
        scrollView.showsHorizontalScrollIndicator = false
        
//        scrollView.addSubview(self.headerView)
//        scrollView.addSubview(self.collectionContainerView)
        scrollView.addSubview(self.contentView)
        
//        self.headerView.anchor(top: scrollView.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
//        self.headerView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
//        self.headerView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40).isActive = true
        
        self.contentView.anchor(top: scrollView.topAnchor, left: nil, bottom: scrollView.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        self.contentView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        self.contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -30).isActive = true
        
        return scrollView
    }()
    
    @objc func endLearn() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func handleSwipes(_ sender: UISwipeGestureRecognizer) {
        var nextView: ILearnView?
        var tempContraints: NSLayoutConstraint?
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            switch sender.direction {
            case .left:
                print("Left Swipe")
                if self.currCardNumber < self.data.cardsAmount - 1 {
                    self.contentView.transform = CGAffineTransform(translationX: -self.view.frame.width, y: 0)
                    UIView.performWithoutAnimation {
                        nextView = self.learnViews[self.currCardNumber + 1]
                        self.scrollView.addSubview(nextView!)
                        nextView!.translatesAutoresizingMaskIntoConstraints = false
                        nextView!.topAnchor.constraint(equalTo: self.scrollView.topAnchor).isActive = true
//                        tempContraints = nextView!.bottomAnchor.constraint(equalTo: self.contentView.controlsView.bottomAnchor)
//                        tempContraints?.isActive = true
                        
                        nextView!.centerXAnchor.constraint(equalTo: self.scrollView.centerXAnchor).isActive = true
                        nextView!.widthAnchor.constraint(equalTo: self.scrollView.widthAnchor, constant: -30).isActive = true
                        
                        nextView?.transform = CGAffineTransform(translationX: self.view.frame.width, y: 0)
                    }
                    nextView?.transform = CGAffineTransform(translationX: 0, y: 0)
                }
            case .right:
                print("Right Swipe")
                if self.currCardNumber > 0 {
                    self.contentView.transform = CGAffineTransform(translationX: self.view.frame.width, y: 0)
                    UIView.performWithoutAnimation {
                        nextView = self.learnViews[self.currCardNumber - 1]
                        nextView!.translatesAutoresizingMaskIntoConstraints = false

                        self.scrollView.addSubview(nextView!)
                        
                        nextView!.topAnchor.constraint(equalTo: self.scrollView.topAnchor).isActive = true
//                        tempContraints = nextView!.bottomAnchor.constraint(equalTo: self.contentView.controlsView.bottomAnchor)
//                        tempContraints?.isActive = true
                        
                        nextView!.centerXAnchor.constraint(equalTo: self.scrollView.centerXAnchor).isActive = true
                        nextView!.widthAnchor.constraint(equalTo: self.scrollView.widthAnchor, constant: -30).isActive = true
                        
                        nextView?.transform = CGAffineTransform(translationX: -self.view.frame.width, y: 0)
                    }
                    nextView?.transform = CGAffineTransform(translationX: 0, y: 0)
                }
            default:
                print("break")
                break
            }
        }) { (_) in
            self.contentView.removeFromSuperview()
            tempContraints?.isActive = false
            nextView?.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor).isActive = true
            switch sender.direction {
            case .left:
                if self.currCardNumber < self.data.cardsAmount - 1 {
                    self.currCardNumber += 1
                }
            case .right:
                if self.currCardNumber > 0 {
                    self.currCardNumber -= 1
                }
            default:
                break
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let recognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        recognizer.direction = .left
        recognizer.delegate = self
        let recognizer1 = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        recognizer1.direction = .right
        recognizer1.delegate = self
        self.scrollView.addGestureRecognizer(recognizer)
        self.scrollView.addGestureRecognizer(recognizer1)

        
        self.tabBarController?.tabBar.isHidden = true
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Закончить", style: .done, target: self, action: #selector(endLearn))
        
        self.view.backgroundColor = .white
        
        self.view.addSubview(scrollView)
        scrollView.anchor(top: self.view.topAnchor, left: self.view.leftAnchor, bottom: self.view.bottomAnchor, right: self.view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: UIScreen.main.bounds.width, height: 0)
        self.navigationItem.title = self.data.dictName
        self.navigationItem.setHidesBackButton(true, animated:true)
    }
    
    init(data: ILearnViewControllerData, learnViews: [ILearnView]) {
        self.data = data
        self.learnViews = learnViews
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension LearnCollectionViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.contentOffset.x = 0
    }
}


extension LearnCollectionViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
