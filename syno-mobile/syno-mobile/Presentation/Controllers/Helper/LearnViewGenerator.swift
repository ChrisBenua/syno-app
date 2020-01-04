//
//  LearnViewGenerator.swift
//  syno-mobile
//
//  Created by Ирина Улитина on 22.12.2019.
//  Copyright © 2019 Christian Benua. All rights reserved.
//

import Foundation
import UIKit

protocol ILearnView: UIView, ILearnControllerDataSourceReactor {
    var controlsView: UIView { get }
}

class LearnView: UIView, ILearnView {
    var dataSource: ILearnControllerTableViewDataSource
    weak var actionsDelegate: ILearnControllerActionsDelegate?
    weak var scrollViewDelegate: UIScrollViewDelegate?
    
    func setHeaderData() {
        cardNumberLabel.text = "\(self.dataSource.state.itemNumber + 1)/\(self.dataSource.viewModel.count)"
        translationsNumberLabel.text = "\(self.dataSource.viewModel.getItems(currCardPos: self.dataSource.state.itemNumber).count) переводов"
        translatedWordView.translatedWordLabel.text = self.dataSource.viewModel.getTranslatedWord(cardPos: self.dataSource.state.itemNumber)
    }
    
    lazy var tableView: UITableView = {
        let tableView = PlainTableView()
        tableView.delegate = self.dataSource
        tableView.dataSource = self.dataSource
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        
        tableView.register(TranslationReadonlyTableViewCell.self, forCellReuseIdentifier: TranslationReadonlyTableViewCell.cellId())
        
        return tableView
    }()
    
    lazy var collectionContainerView: UIView = {
        let view = BaseShadowView()
        view.shadowView.shadowOffset = CGSize(width: 0, height: 4)

        view.containerViewBackgroundColor = UIColor(red: 247.0/255, green: 247.0/255, blue: 247.0/255, alpha: 1)
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
    
    lazy var translatedWordView: TranslatedWordView = {
        let translatedWordView = TranslatedWordView()
        translatedWordView.translatedWordLabel.isUserInteractionEnabled = false
        
        return translatedWordView
    }()
    
    lazy var headerView: UIView = {
        let view = UIView()
        
        
        let cardNumberLabel = self.cardNumberLabel
        
        let translationsNumberLabel = self.translationsNumberLabel
        
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
        let plusOneButton = CommonUIElements.defaultSubmitButton(text: "+1", backgroundColor: UIColor.init(red: 96.0/255, green: 157.0/255, blue: 248.0/255, alpha: 1.0))
        plusOneButton.addTarget(self, action: #selector(onPlusOneClick), for: .touchUpInside)
        
        let showAllButton = CommonUIElements.defaultSubmitButton(text: "Все", backgroundColor: UIColor.init(red: 96.0/255, green: 157.0/255, blue: 248.0/255, alpha: 1.0))
        showAllButton.addTarget(self, action: #selector(onShowAllClick), for: .touchUpInside)
        
        let view = UIView()
        view.addSubview(plusOneButton)
        view.addSubview(showAllButton)
        
        plusOneButton.anchor(top: view.topAnchor, left: nil, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 10, paddingLeft: 0, paddingBottom: 10, paddingRight: 30, width: 0, height: 0)
        showAllButton.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: nil, paddingTop: 10, paddingLeft: 30, paddingBottom: 10, paddingRight: 0, width: 0, height: 0)
        
        plusOneButton.widthAnchor.constraint(equalTo: showAllButton.widthAnchor).isActive = true
        showAllButton.widthAnchor.constraint(greaterThanOrEqualTo: view.widthAnchor, multiplier: 0.15).isActive = true
        
        return view
    }()
    
    lazy var cardNumberLabel: UILabel = {
        let cardNumberLabel = UILabel(); cardNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        cardNumberLabel.font = UIFont.systemFont(ofSize: 20)
        cardNumberLabel.textAlignment = .center
        
        return cardNumberLabel
    }()
    
    lazy var translationsNumberLabel: UILabel = {
        let translationsNumberLabel = UILabel(); translationsNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        translationsNumberLabel.font = UIFont.systemFont(ofSize: 20)
        translationsNumberLabel.textAlignment = .center
        
        return translationsNumberLabel
    }()
    
    init(dataSource: ILearnControllerTableViewDataSource, actionsDelegate: ILearnControllerActionsDelegate?, scrollViewDelegate: UIScrollViewDelegate?) {
        self.dataSource = dataSource
        self.actionsDelegate = actionsDelegate
        self.scrollViewDelegate = scrollViewDelegate
        super.init(frame: .zero)
        
        self.addSubview(self.contentView)
        self.contentView.anchor(top: self.topAnchor, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        setHeaderData()
        //self.contentView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1).isActive = true
        //self.contentView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 1).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func onPlusOneClick() {
        self.actionsDelegate?.onPlusOne()
    }
        
    @objc func onShowAllClick() {
        self.actionsDelegate?.onShowAll()
    }
    
    lazy var contentView: UIView = {
        let view = UIView()
        view.addSubview(self.headerView)
        view.addSubview(self.collectionContainerView)
        
        self.headerView.anchor(top: view.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        self.headerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        self.headerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -40).isActive = true
        
        self.collectionContainerView.anchor(top: self.headerView.bottomAnchor, left: nil, bottom: view.bottomAnchor, right: nil, paddingTop: 10, paddingLeft: 0, paddingBottom: 20, paddingRight: 0, width: 0, height: 0)
        self.collectionContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        self.collectionContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: 0).isActive = true
        
        return view
    }()
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        scrollView.alwaysBounceHorizontal = false
        scrollView.delegate = scrollViewDelegate
        scrollView.showsHorizontalScrollIndicator = false
        
//        scrollView.addSubview(self.headerView)
//        scrollView.addSubview(self.collectionContainerView)
        scrollView.addSubview(self.contentView)
        
//        self.headerView.anchor(top: scrollView.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
//        self.headerView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
//        self.headerView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40).isActive = true
        
        self.contentView.anchor(top: scrollView.topAnchor, left: nil, bottom: scrollView.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        self.contentView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        self.contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -20).isActive = true
        
        return scrollView
    }()
}

extension LearnView: ILearnControllerDataSourceReactor {
//    func reload() {
//        self.tableView.reloadData()
//        self.setHeaderData()
//    }
    
    func addItems(indexPaths: [IndexPath]) {
        self.tableView.insertRows(at: indexPaths, with: .automatic)
    }
}

class LearnViewGenerator {
    func generate(dataSource: ILearnControllerTableViewDataSource, actionsDelegate: ILearnControllerActionsDelegate?, scrollViewDelegate: UIScrollViewDelegate?) -> LearnView {
        return LearnView(dataSource: dataSource, actionsDelegate: actionsDelegate, scrollViewDelegate: scrollViewDelegate)
    }
}
