//
//  TestController.swift
//  syno-mobile
//
//  Created by Ирина Улитина on 05.01.2020.
//  Copyright © 2020 Christian Benua. All rights reserved.
//

import Foundation
import UIKit

class TestViewController: UIViewController, IScrollableToPoint {
    private var lastFocusedPoint: CGPoint?
    
    private var presAssembly: IPresentationAssembly
    
    private var currCardNumber: Int = 0
    
    func scrollToPoint(point: CGPoint) {
        print("scrollToPoint")
        lastFocusedPoint = point
    }
    
    func scrollToTop() {
        scrollToTop(self.scrollView, animated: true)
    }
    
    func scrollToTop(_ scrollView: UIScrollView, animated: Bool = true) {
        self.scrollView.contentInset.bottom = 0
        if #available(iOS 11.0, *) {
            let expandedBar = (navigationController?.navigationBar.frame.height ?? 64.0 > 44.0)
            let largeTitles = (navigationController?.navigationBar.prefersLargeTitles) ?? false
            let offset: CGFloat = (largeTitles && !expandedBar) ? 52: 0
            scrollView.setContentOffset(CGPoint(x: 0, y: -(scrollView.adjustedContentInset.top + offset)), animated: animated)
        } else {
            scrollView.setContentOffset(CGPoint(x: 0, y: -scrollView.contentInset.top), animated: animated)
        }
    }
    
    private var testViews: [ITestView]
    
    var contentView: UIView {
        get {
            testViews[currCardNumber].parentController = self
            return testViews[currCardNumber]
        }
    }
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        scrollView.alwaysBounceHorizontal = false
        scrollView.showsHorizontalScrollIndicator = true
        
        scrollView.addSubview(self.contentView)
        
        self.contentView.anchor(top: scrollView.contentLayoutGuide.topAnchor, left: nil, bottom: scrollView.contentLayoutGuide.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        self.contentView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        self.contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -30).isActive = true
        
        return scrollView
    }()
    
    init(testViews: [ITestView], dictName: String, presAssembly: IPresentationAssembly) {
        self.testViews = testViews
        self.presAssembly = presAssembly
        super.init(nibName: nil, bundle: nil)
        
        self.navigationItem.title = dictName
        
        self.tabBarController?.tabBar.isHidden = true
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Закончить", style: .done, target: self, action: #selector(endTest))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Отмена", style: .done, target: self, action: #selector(cancelTest))
        
        self.view.backgroundColor = .white
        
        self.view.addSubview(scrollView)
        scrollView.anchor(top: self.view.topAnchor, left: self.view.leftAnchor, bottom: self.view.bottomAnchor, right: self.view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: UIScreen.main.bounds.width, height: 0)
        self.navigationItem.setHidesBackButton(true, animated:true)
    }
    
    @objc func cancelTest() {
        print("cancelTest")
        
        self.testViews[currCardNumber].model.cancelTest {
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @objc func endTest() {
        print("endTest")
        self.testViews[currCardNumber].model.endTest { (test) in
            DispatchQueue.main.async {
                let okAction = UIAlertAction(title: "Ok", style: .default) { (_) in
                    self.navigationController?.pushViewController(self.presAssembly
                        .testResultsController(sourceTest: test), animated: true)
                }
                let alertController = UIAlertController(title: "Success", message: "Test ended!", preferredStyle: .alert)
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    func handleSwipes(_ sender: UISwipeGestureRecognizer) {
        var success = false
        var nextView: ITestView?
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            switch sender.direction {
            case .left:
                if (self.currCardNumber < self.testViews.count - 1) {
                    success = true
                    self.contentView.transform = CGAffineTransform(translationX: -self.view.frame.width, y: 0)
                    UIView.performWithoutAnimation {
                        nextView = self.testViews[self.currCardNumber + 1]
                        self.scrollView.addSubview(nextView!)
                        nextView!.translatesAutoresizingMaskIntoConstraints = false
                        nextView!.topAnchor.constraint(equalTo: self.scrollView.topAnchor).isActive = true
                        
                        nextView!.centerXAnchor.constraint(equalTo: self.scrollView.centerXAnchor).isActive = true
                        nextView!.widthAnchor.constraint(equalTo: self.scrollView.widthAnchor, constant: -30).isActive = true
                        
                        nextView?.transform = CGAffineTransform(translationX: self.view.frame.width, y: 0)
                    }
                    nextView?.transform = CGAffineTransform(translationX: 0, y: 0)
                }
                break
            case .right:
                print("Right Swipe")
                if self.currCardNumber > 0 {
                    success = true
                    self.contentView.transform = CGAffineTransform(translationX: self.view.frame.width, y: 0)
                    UIView.performWithoutAnimation {
                        nextView = self.testViews[self.currCardNumber - 1]
                        nextView!.translatesAutoresizingMaskIntoConstraints = false

                        self.scrollView.addSubview(nextView!)
                        
                        nextView!.topAnchor.constraint(equalTo: self.scrollView.topAnchor).isActive = true
                        nextView!.centerXAnchor.constraint(equalTo: self.scrollView.centerXAnchor).isActive = true
                        nextView!.widthAnchor.constraint(equalTo: self.scrollView.widthAnchor, constant: -30).isActive = true
                        
                        nextView?.transform = CGAffineTransform(translationX: -self.view.frame.width, y: 0)
                    }
                    nextView?.transform = CGAffineTransform(translationX: 0, y: 0)
                }
                break
            default:
                break
            }
        }) { (_) in
            if (success) {
                self.contentView.removeFromSuperview()
                nextView?.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor).isActive = true
                switch sender.direction {
                case .left:
                    if self.currCardNumber < self.testViews.count - 1 {
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
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .yellow
        self.view.addSubview(scrollView)
        
        let recognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        recognizer.direction = .left
        recognizer.delegate = self

        let recognizer1 = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        recognizer1.direction = .right
        recognizer1.delegate = self
        
        self.scrollView.addGestureRecognizer(recognizer)
        self.scrollView.addGestureRecognizer(recognizer1)
        
        let allViewTapGestureReco = UITapGestureRecognizer(target: self, action: #selector(clearKeyboard))
        view.addGestureRecognizer(allViewTapGestureReco)
        allViewTapGestureReco.cancelsTouchesInView = false
        
        self.addKeyboardObservers(showSelector: #selector(showKeyboard(notification:)), hideSelector: #selector(hideKeyboard(notification:)))
        
        scrollView.anchor(top: self.view.topAnchor, left: self.view.leftAnchor, bottom: self.view.bottomAnchor, right: self.view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: UIScreen.main.bounds.width, height: 0)
    }
}

extension TestViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension TestViewController {
    
    @objc func showKeyboard(notification: NSNotification) {
        if let keyboardHeight = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height {
            print("lastPoint: \(lastFocusedPoint?.y)")
            print("keyboard height:\(keyboardHeight)")
            
            let neededShift = UIScreen.main.bounds.height - lastFocusedPoint!.y - keyboardHeight + 60
            if (neededShift < 0) {
                self.scrollView.contentInset.bottom = -neededShift + scrollView.contentOffset.y + 20
                self.scrollView.setContentOffset(CGPoint(x: 0, y: -neededShift), animated: true)
            }
        }
    }
    
    @objc func hideKeyboard(notification: NSNotification) {
        Logger.log("Hide")
    }
    
    @objc func clearKeyboard() {
        view.endEditing(true)
    }
}
