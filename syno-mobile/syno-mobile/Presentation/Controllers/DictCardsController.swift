//
//  DictCardsController.swift
//  syno-mobile
//
//  Created by Ирина Улитина on 12.12.2019.
//  Copyright © 2019 Christian Benua. All rights reserved.
//

import Foundation
import UIKit


class DictCardsController: UIViewController {
    
    private let rowHeight: CGFloat = 80
    
    var frcDelegate: IDefaultCollectionViewFetchResultControllerDelegate?
    
    var dataSource: ICardsControllerDataSource
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let colView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        colView.alwaysBounceVertical = true
        colView.backgroundColor = .white
        colView.delegate = self.dataSource
        
        colView.contentInset = UIEdgeInsets(top: 30, left: 15, bottom: 0, right: 15)
        
        colView.register(CardCollectionViewCell.self, forCellWithReuseIdentifier: CardCollectionViewCell.cellId)
        
        return colView
    }()
    
    let assembly: IPresentationAssembly
    
    init(dataSource: ICardsControllerDataSource, presAssembly: IPresentationAssembly) {
        self.dataSource = dataSource
        self.assembly = presAssembly
        super.init(nibName: nil, bundle: nil)
        frcDelegate = DefaultCollectionViewFRCDelegate(collectionView: self.collectionView)
        self.dataSource.fetchedResultsController.delegate = frcDelegate
        self.dataSource.delegate = self
        self.collectionView.dataSource = self.dataSource
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Карточки"
        
        self.dataSource.performFetch()
        self.view.addSubview(self.collectionView)
        
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "Group 6"), style: .plain, target: self, action: #selector(addCard))
        
        collectionView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        collectionView.reloadData()
    }
    
    @objc func addCard() {
        let controller = self.assembly.newCardController()
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


extension DictCardsController: ICardsDataSourceReactor {
    func onSelectedItem(item: DbUserCard) {
        let controller = self.assembly.translationsViewController(sourceCard: item)
        self.navigationController?.pushViewController(controller, animated: true)
    }
}
