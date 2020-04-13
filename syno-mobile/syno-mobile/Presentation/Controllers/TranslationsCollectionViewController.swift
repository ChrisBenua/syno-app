//
//  TranslationsCollectionViewController.swift
//  syno-mobile
//
//  Created by Ирина Улитина on 13.12.2019.
//  Copyright © 2019 Christian Benua. All rights reserved.
//

import Foundation
import UIKit

class TranslationsCollectionViewController: UIViewController, IScrollableToPoint {
    func scrollToPoint(point: CGPoint) {
        print("")
    }
    
    func scrollToTop() {
        print(#function)
        scrollToTop(self.scrollView, animated: true)
    }
    
    func scrollToTop(_ scrollView: UIScrollView, animated: Bool = true) {
        self.scrollView.contentInset.bottom = 0
        if #available(iOS 11.0, *) {
            let expandedBar = (navigationController?.navigationBar.frame.height ?? 64.0 > 44.0)
            let largeTitles = (navigationController?.navigationBar.prefersLargeTitles) ?? false
            let offset: CGFloat = (largeTitles && !expandedBar) ? 52: 0
            print("Setting content offsest")
            scrollView.setContentOffset(CGPoint(x: 0, y: -(scrollView.adjustedContentInset.top + offset)), animated: animated)
        } else {
            scrollView.setContentOffset(CGPoint(x: 0, y: -scrollView.contentInset.top), animated: animated)
        }
    }
    
    
    var dataSource: ITranslationControllerDataSource
    
    lazy var processingSaveView: SavingProcessView = {
        let view = SavingProcessView()
        view.setText(text: "Saving")
        
        return view
    }()
    
    lazy var layout: UICollectionViewFlowLayout = {
        return UICollectionViewFlowLayout()
    }()
    
    lazy var controlsView: UIView = {
        let addButton = UIButton(type: .custom)
        addButton.setBackgroundImage(#imageLiteral(resourceName: "Group 6"), for: .normal)
        
        addButton.addTarget(self, action: #selector(onAddAnswerButton), for: .touchUpInside)
        
        let view = UIView()
        view.addSubview(addButton)

        addButton.anchor(top: view.topAnchor, left: nil, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 25, width: 0, height: 0)
        addButton.widthAnchor.constraint(greaterThanOrEqualTo: view.widthAnchor, multiplier: 0.08).isActive = true
        addButton.heightAnchor.constraint(equalTo: addButton.widthAnchor, multiplier: 1).isActive = true
        addButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 30).isActive = true
        
        return view
    }()
    
    @objc func onAddAnswerButton() {
        self.dataSource.add()
    }
    
    lazy var tableView: UITableView = {
        
        let tableView = PlainTableView()
        
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        
        tableView.alwaysBounceVertical = false
        tableView.isScrollEnabled = false
        
        tableView.backgroundColor = UIColor.clear
        
        tableView.delegate = self.dataSource
        tableView.dataSource = self.dataSource
        
        tableView.separatorStyle = .none
        
        tableView.contentInset = UIEdgeInsets(top: 30, left: 0, bottom: 10, right: 0)
        
        tableView.register(TranslationTableViewCell.self, forCellReuseIdentifier: TranslationTableViewCell.cellId())
        
        return tableView
    }()
    
    lazy var collectionContainerView: UIView = {
        let view = BaseShadowView()
        view.shadowView.shadowOffset = CGSize(width: 0, height: 4)

        view.containerViewBackgroundColor = UIColor(red: 247.0/255, green: 247.0/255, blue: 247.0/255, alpha: 1)
        view.cornerRadius = 20
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(self.tableView)
        view.addSubview(self.controlsView)
        
        self.controlsView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        self.tableView.anchor(top: self.controlsView.bottomAnchor, left: nil, bottom: view.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 10, paddingRight: 0, width: 0, height: 0)
        self.tableView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -30).isActive = true
        self.tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        return view
    }()
    
    lazy var collectionViewHeader: UIView = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .regular)
        label.text = "Переводы"
        label.textAlignment = .center
        
        return label
    }()
    
    lazy var translatedWordHeader: UIView = {
        let header = TranslatedWordView()
        header.translatedWordLabel.text = self.dataSource.viewModel.sourceCard.translatedWord
        header.translatedWordLabel.addTarget(self, action: #selector(onTranslatedWordChanded(_:)), for: .editingChanged)
        
        return header
    }()
    
    @objc func onTranslatedWordChanded(_ textField: UITextField) {
        self.dataSource.updateTranslatedWord(newTranslatedWord: textField.text)
    }
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        scrollView.alwaysBounceHorizontal = false
        scrollView.delegate = self
        scrollView.showsHorizontalScrollIndicator = false
        
        scrollView.addSubview(self.collectionContainerView)
        scrollView.addSubview(self.collectionViewHeader)
        scrollView.addSubview(self.translatedWordHeader)
        
        self.translatedWordHeader.anchor(top: scrollView.contentLayoutGuide.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        self.translatedWordHeader.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        self.translatedWordHeader.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: 1, constant: -30).isActive = true
        
        self.collectionViewHeader.anchor(top: self.translatedWordHeader.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        self.collectionViewHeader.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        self.collectionViewHeader.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        
        return scrollView
    }()

    init(dataSource: ITranslationControllerDataSource) {
        self.dataSource = dataSource
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Карточки"
        self.view.backgroundColor = .white
        
        let allViewTapGestureReco = UITapGestureRecognizer(target: self, action: #selector(clearKeyboard(_:)))
        view.addGestureRecognizer(allViewTapGestureReco)
        allViewTapGestureReco.cancelsTouchesInView = false
        allViewTapGestureReco.delegate = self
        
        self.addKeyboardObservers(showSelector: #selector(showKeyboard(notification:)), hideSelector: #selector(hideKeyboard(notification:)))
        
        self.view.addSubview(scrollView)
        layout.estimatedItemSize = CGSize(width: UIScreen.main.bounds.width - 40, height: 100)
        scrollView.anchor(top: self.view.topAnchor, left: self.view.leftAnchor, bottom: self.view.bottomAnchor, right: self.view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: UIScreen.main.bounds.width, height: 0)
        //scrollView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 1).isActive = true
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Сохранить", style: .plain, target: self, action: #selector(onSaveButtonPressed))
        
        self.collectionContainerView.anchor(top: self.collectionViewHeader.bottomAnchor, left: nil, bottom: scrollView.bottomAnchor, right: nil, paddingTop: 10, paddingLeft: 0, paddingBottom: 20, paddingRight: 0, width: 0, height: 0)
       self.collectionContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
       self.collectionContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -30).isActive = true
    }
    
    @objc func onSaveButtonPressed() {
        self.processingSaveView.showSavingProcessView(sourceView: self)
        self.dataSource.save {
            DispatchQueue.main.async {
                let timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { (timer) in
                    self.processingSaveView.dismissSavingProcessView()
                    self.navigationController?.popViewController(animated: true)
                }
                
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TranslationsCollectionViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.contentOffset.x = 0
    }
}

extension TranslationsCollectionViewController {
    
    @objc func showKeyboard(notification: NSNotification) {
        if let keyboardHeight = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height {
            print("keyboard height:\(keyboardHeight)")
            
            if let lastFocusedPoint = self.dataSource.getLastFocusedPoint() {
                print("Last Focused Point: \(lastFocusedPoint)")
                let point = self.tableView.convert(lastFocusedPoint, to: self.view)
                print("Converted Point: \(point)")
                let neededShift = UIScreen.main.bounds.height - point.y - keyboardHeight - 40
                print("Needed shift: \(neededShift)")
                if (neededShift < 0) {
                    print(scrollView.contentOffset)
                    self.scrollView.contentInset.bottom = -neededShift + scrollView.contentOffset.y + 20
                    self.scrollView.setContentOffset(CGPoint(x: 0, y: -neededShift + scrollView.contentOffset.y), animated: true)
                }
            }
        }
    }
    
    @objc func hideKeyboard(notification: Notification) {
        Logger.log("Hide")
    }
    
    @objc func clearKeyboard(_ sender: UITapGestureRecognizer) {
        print(sender.location(in: self.view))
        view.endEditing(true)
        self.scrollToTop()
    }
}

extension TranslationsCollectionViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        print(#function)
        return false
    }
}

