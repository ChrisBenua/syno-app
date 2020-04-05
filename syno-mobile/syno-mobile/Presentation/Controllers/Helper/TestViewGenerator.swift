//
//  TestViewGenerator.swift
//  syno-mobile
//
//  Created by Ирина Улитина on 05.01.2020.
//  Copyright © 2020 Christian Benua. All rights reserved.
//

import Foundation
import UIKit

protocol IScrollableToPoint: class {
    func scrollToPoint(point: CGPoint)
    
    func scrollToTop()
}

protocol ITestView: UIView, ITestViewControllerDataSourceReactor, IScrollableToPoint {
    var tableView: UITableView { get }
    var parentController: IScrollableToPoint? { get set }
    
    var model: ITestViewControllerModel { get }
}

class TestView: UIView, ITestView {
    func scrollToTop() {
        parentController?.scrollToTop()
    }
    
    func scrollToPoint(point: CGPoint) {
        parentController?.scrollToPoint(point: point)
    }
    
    weak var parentController: IScrollableToPoint?
    var model: ITestViewControllerModel
    
    func setHeaderData() {
        self.cardNumberLabel.text = "\(model.dataSource.state.itemNumber + 1)/\(model.dataSource.dataProvider.count)"
        self.translatedWordView.translatedWordLabel.text = model.dataSource.dataProvider.getItem(cardPos: model.dataSource.state.itemNumber).translatedWord
        self.translationsNumberLabel.text = "\(model.dataSource.dataProvider.getItem(cardPos: model.dataSource.state.itemNumber).translationsCount) переводов"
    }
    
    lazy var cardNumberLabel: UILabel = {
        let cardNumberLabel = UILabel(); cardNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        cardNumberLabel.font = UIFont.systemFont(ofSize: 20)
        cardNumberLabel.textAlignment = .center
        
        return cardNumberLabel
    }()
    
    lazy var translatedWordView: TranslatedWordView = {
        let wordView = TranslatedWordView()
        wordView.translatedWordLabel.isUserInteractionEnabled = false
        
        return wordView
    }()
    
    lazy var translationsNumberLabel: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        
        return label
    }()
    
    lazy var headerView: UIView = {
        let view = UIView()
        
        let sepView = UIView(); sepView.translatesAutoresizingMaskIntoConstraints = false
        let sepView1 = UIView(); sepView1.translatesAutoresizingMaskIntoConstraints = false
        
        let sv = UIStackView(arrangedSubviews: [cardNumberLabel, sepView, translatedWordView, sepView1, translationsNumberLabel])
        sv.axis = .vertical
        sv.distribution = .fill
        
        sepView.heightAnchor.constraint(equalTo: sv.heightAnchor, multiplier: 0.2).isActive = true
        sepView1.heightAnchor.constraint(equalTo: sv.heightAnchor, multiplier: 0.15).isActive = true
        
        view.addSubview(sv)
        sv.anchor(top: view.topAnchor, left: nil, bottom: view.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        sv.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        sv.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1).isActive = true
        
        return view
    }()
    
    lazy var controlsView: UIView = {
        let addButton = CommonUIElements.defaultSubmitButton(text: "+", backgroundColor: UIColor.init(red: 96.0/255, green: 157.0/255, blue: 248.0/255, alpha: 1.0))
        
        addButton.addTarget(self, action: #selector(onAddAnswerButton), for: .touchUpInside)
        
        let view = UIView()
        view.addSubview(addButton)

        addButton.anchor(top: view.topAnchor, left: nil, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 10, paddingLeft: 0, paddingBottom: 10, paddingRight: 20, width: 0, height: 0)
        addButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.12).isActive = true
        
        return view
    }()
    
    @objc func onAddAnswerButton() {
        if (self.model.dataSource.dataProvider.getItem(cardPos: self.model.dataSource.state.itemNumber).translationsCount > tableView.numberOfRows(inSection: 0)) {
            self.model.dataSource.onAddLineForAnswer()
        }
    }
    
    lazy var tableView: UITableView = {
        let tv = PlainTableView()
        tv.dataSource = self.model.dataSource
        tv.delegate = self.model.dataSource
        
        tv.backgroundColor = .clear
        tv.separatorColor = .clear
        
        tv.separatorInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        tv.separatorInsetReference = .fromCellEdges
        
        tv.register(TestControllerTranslationTableViewCell.self, forCellReuseIdentifier: TestControllerTranslationTableViewCell.cellId)
        
        return tv
    }()
    
    lazy var collectionContainerView: UIView = {
        let view = BaseShadowView()
        view.shadowView.shadowOffset = CGSize(width: 0, height: 4)

        view.containerViewBackgroundColor = UIColor(red: 240.0/255, green: 240.0/255, blue: 240.0/255, alpha: 1)
        view.cornerRadius = 20
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(self.controlsView)
        view.addSubview(self.tableView)
        
        self.controlsView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 5, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        self.tableView.anchor(top: self.controlsView.bottomAnchor, left: nil, bottom: view.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 10, paddingRight: 15, width: 0, height: 0)
        self.tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        self.tableView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -25).isActive = true
        
        return view
    }()
    
    lazy var contentView: UIView = {
        let view = UIView()
        view.addSubview(self.headerView)
        view.addSubview(self.collectionContainerView)
        
        self.headerView.anchor(top: view.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        self.headerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        self.headerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -40).isActive = true
        
        self.collectionContainerView.anchor(top: self.headerView.bottomAnchor, left: nil, bottom: view.bottomAnchor, right: nil, paddingTop: 10, paddingLeft: 0, paddingBottom: 20, paddingRight: 0, width: 0, height: 0)
        self.collectionContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        self.collectionContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: 0).isActive = true
        
        return view
    }()
    
    init(model: ITestViewControllerModel) {
        self.model = model
        super.init(frame: .zero)
        self.model.dataSource.reactor = self
        self.model.dataSource.onFocusedLabelDelegate = self

        
        self.addSubview(self.contentView)
        self.contentView.anchor(top: self.topAnchor, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        setHeaderData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addItems(indexPaths: [IndexPath]) {
        self.tableView.insertRows(at: indexPaths, with: .automatic)
    }
    
    func deleteItems(indexPaths: [IndexPath]) {
        self.tableView.deleteRows(at: indexPaths, with: .automatic)
    }
}

class TestViewGenerator {
    func generate(model: ITestViewControllerModel) -> ITestView {
        return TestView(model: model)
    }
}
