//
//  TestAndLearnController.swift
//  syno-mobile
//
//  Created by Ирина Улитина on 16.12.2019.
//  Copyright © 2019 Christian Benua. All rights reserved.
//

import Foundation
import UIKit

extension UISegmentedControl {
    func updateColors(selectedColor: UIColor) {
        for (index, subview) in self.subviews.enumerated() {
            if index == self.selectedSegmentIndex {
                subview.tintColor = selectedColor
            }
            else {
                subview.tintColor = self.tintColor
            }
        }
    }
}

class TestAndLearnViewController: UIViewController {
    
    var frcDelegate: IDefaultCollectionViewFetchResultControllerDelegate?
    
    var dataSource: ITestAndLearnDictionaryDataSource
    
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let colView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        colView.alwaysBounceVertical = true
        colView.backgroundColor = .white
        colView.delegate = self.dataSource
        
        colView.contentInset = UIEdgeInsets(top: 5, left: 15, bottom: 0, right: 15)
        
        colView.register(TestAndLearnCollectionViewCell.self, forCellWithReuseIdentifier: TestAndLearnCollectionViewCell.cellId)
        colView.register(TestAndLearnControllerHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TestAndLearnControllerHeader.headerId)
        
        return colView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("testAndLearnViewController")
        self.navigationItem.title = "Обучение"
        
        self.dataSource.performFetch()
        self.view.addSubview(self.collectionView)
        
        collectionView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        collectionView.reloadData()
    }
    
    init(datasource: ITestAndLearnDictionaryDataSource) {
        self.dataSource = datasource
        super.init(nibName: nil, bundle: nil)
        frcDelegate = DefaultCollectionViewFRCDelegate(collectionView: self.collectionView)
        self.dataSource.fetchedResultsController.delegate = frcDelegate
        self.collectionView.dataSource = self.dataSource
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

