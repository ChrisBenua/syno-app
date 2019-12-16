//
//  DictsController.swift
//  syno-mobile
//
//  Created by Ирина Улитина on 05.12.2019.
//  Copyright © 2019 Christian Benua. All rights reserved.
//

import Foundation
import UIKit

class DictsViewController: UIViewController, IDictionaryControllerReactor {
    func showCardsController(controller: UIViewController) {
        self.navigationController!.pushViewController(controller, animated: true)
    }
    
    private let rowHeight: CGFloat = 80
    
    var frcDelegate: IDefaultCollectionViewFetchResultControllerDelegate?
    
    var dataSource: IDictionaryControllerTableViewDataSource
    
    var model: IDictControllerModel
    
    init(datasource: IDictionaryControllerTableViewDataSource, model: IDictControllerModel) {
        self.dataSource = datasource
        self.model = model
        super.init(nibName: nil, bundle: nil)
        frcDelegate = DefaultCollectionViewFRCDelegate(collectionView: self.collectionView)
        self.dataSource.fetchedResultsController.delegate = frcDelegate
        self.collectionView.dataSource = self.dataSource
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let colView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        colView.alwaysBounceVertical = true
        colView.backgroundColor = .white
        colView.delegate = self.dataSource
        
        colView.contentInset = UIEdgeInsets(top: 30, left: 15, bottom: 0, right: 15)
        
        colView.register(DictionaryCollectionViewCell.self, forCellWithReuseIdentifier: DictionaryCollectionViewCell.cellId)
        
        return colView
    }()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLoad() {
        self.navigationItem.title = "Словари"

//        self.view.addSubview(self.tableView)
//
//        tableView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        self.dataSource.performFetch()
        self.dataSource.delegate = self
        //self.tableView.reloadData()
        
        self.view.addSubview(self.collectionView)
        model.initialFetch()

        collectionView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        collectionView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        collectionView.reloadData()
    }
}


