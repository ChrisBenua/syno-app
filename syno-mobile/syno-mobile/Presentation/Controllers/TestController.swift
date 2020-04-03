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
    func scrollToPoint(point: CGPoint) {
        print("scrollToPoint")
        lastFocusedPoint = point
    }
    
    func scrollToTop() {
        scrollToTop(self.scrollView, animated: true)
    }
    
    func scrollToTop(_ scrollView: UIScrollView, animated: Bool = true) {
        if #available(iOS 11.0, *) {
            let expandedBar = (navigationController?.navigationBar.frame.height ?? 64.0 > 44.0)
            let largeTitles = (navigationController?.navigationBar.prefersLargeTitles) ?? false
            let offset: CGFloat = (largeTitles && !expandedBar) ? 52: 0
            scrollView.setContentOffset(CGPoint(x: 0, y: -(scrollView.adjustedContentInset.top + offset)), animated: animated)
        } else {
            scrollView.setContentOffset(CGPoint(x: 0, y: -scrollView.contentInset.top), animated: animated)
        }
    }
    
    private var testView: ITestView
    
    lazy var contentView: UIView = {
        testView.parentController = self
        return testView
    }()
    
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
    
    init(testView: ITestView, dictName: String) {
        self.testView = testView
        super.init(nibName: nil, bundle: nil)
        
        self.navigationItem.title = dictName
        
        self.tabBarController?.tabBar.isHidden = true
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Закончить", style: .done, target: self, action: #selector(endTest))
        
        self.view.backgroundColor = .white
        
        self.view.addSubview(scrollView)
        scrollView.anchor(top: self.view.topAnchor, left: self.view.leftAnchor, bottom: self.view.bottomAnchor, right: self.view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: UIScreen.main.bounds.width, height: 0)
        self.navigationItem.setHidesBackButton(true, animated:true)
    }
    
    @objc func endTest() {
        print("endTest")
        self.navigationController?.popViewController(animated: true)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .yellow
        self.view.addSubview(scrollView)
        
        let allViewTapGestureReco = UITapGestureRecognizer(target: self, action: #selector(clearKeyboard))
        view.addGestureRecognizer(allViewTapGestureReco)
        allViewTapGestureReco.cancelsTouchesInView = false
        
        self.addKeyboardObservers(showSelector: #selector(showKeyboard(notification:)), hideSelector: #selector(hideKeyboard(notification:)))
        
        scrollView.anchor(top: self.view.topAnchor, left: self.view.leftAnchor, bottom: self.view.bottomAnchor, right: self.view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: UIScreen.main.bounds.width, height: 0)
    }
}


extension TestViewController {
    
    @objc func showKeyboard(notification: NSNotification) {
        if let keyboardHeight = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height {
            print("lastPoint: \(lastFocusedPoint?.y)")
            print("keyboard height:\(keyboardHeight)")
            
            let neededShift = UIScreen.main.bounds.height - lastFocusedPoint!.y - keyboardHeight + 60
            if (neededShift < 0) {
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
