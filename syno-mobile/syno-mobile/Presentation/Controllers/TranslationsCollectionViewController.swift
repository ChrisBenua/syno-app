//
//  TranslationsCollectionViewController.swift
//  syno-mobile
//
//  Created by Ирина Улитина on 13.12.2019.
//  Copyright © 2019 Christian Benua. All rights reserved.
//

import Foundation
import UIKit

class TranslationsCollectionViewController: UIViewController {
    
    private var dataSource: ITranslationControllerDataSource
    
    lazy var layout: UICollectionViewFlowLayout = {
        return UICollectionViewFlowLayout()
    }()
    
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
        
        self.tableView.anchor(top: view.topAnchor, left: nil, bottom: view.bottomAnchor, right: nil, paddingTop: 10, paddingLeft: 0, paddingBottom: 10, paddingRight: 0, width: 0, height: 0)
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
        
        return header
    }()
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        scrollView.alwaysBounceHorizontal = false
        scrollView.delegate = self
        scrollView.showsHorizontalScrollIndicator = false
        
        scrollView.addSubview(self.collectionContainerView)
        scrollView.addSubview(self.collectionViewHeader)
        scrollView.addSubview(self.translatedWordHeader)
        
        self.translatedWordHeader.anchor(top: scrollView.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
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
        self.navigationItem.title = "Новая карточка"
        self.view.backgroundColor = .white
        
        self.view.addSubview(scrollView)
        layout.estimatedItemSize = CGSize(width: UIScreen.main.bounds.width - 40, height: 100)
        scrollView.anchor(top: self.view.topAnchor, left: self.view.leftAnchor, bottom: self.view.bottomAnchor, right: self.view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: UIScreen.main.bounds.width, height: 0)
        //scrollView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 1).isActive = true
        
        
        self.collectionContainerView.anchor(top: self.collectionViewHeader.bottomAnchor, left: nil, bottom: scrollView.bottomAnchor, right: nil, paddingTop: 10, paddingLeft: 0, paddingBottom: 20, paddingRight: 0, width: 0, height: 0)
       self.collectionContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
       self.collectionContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -30).isActive = true
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
