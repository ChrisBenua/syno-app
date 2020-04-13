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
    var notifView: BottomNotificationView?
    
    private let rowHeight: CGFloat = 80
    
    var frcDelegate: IDefaultCollectionViewFetchResultControllerDelegate?
    
    var dataSource: IDictionaryControllerTableViewDataSource
    
    var model: IDictControllerModel
    
    init(datasource: IDictionaryControllerTableViewDataSource, model: IDictControllerModel) {
        self.dataSource = datasource
        self.model = model
        super.init(nibName: nil, bundle: nil)
        frcDelegate = DictsControllerCollectionViewFRCDelegate(collectionView: self.collectionView)
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.notifView?.removeFromSuperview()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        collectionView.reloadData()
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
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(onAddNewDictionary))

        collectionView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        collectionView.reloadData()
    }
    
    @objc func onAddNewDictionary() {
        self.navigationController?.pushViewController(self.dataSource.getNewDictController(), animated: true)
    }
    
    func onItemDeleted() {
        let notifView = BottomNotificationView()
        notifView.cancelButtonLabel.text = "Отмена"
        notifView.messageLabel.text = "Словарь будет удален"
        notifView.timerLabel.text = "5"
        notifView.delegate = self
        self.view.addSubview(notifView)
        self.view.bringSubviewToFront(notifView)
        
        notifView.anchor(top: nil, left: self.view.safeAreaLayoutGuide.leftAnchor, bottom: self.view.safeAreaLayoutGuide.bottomAnchor, right: self.view.safeAreaLayoutGuide.rightAnchor, paddingTop: 0, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width: 0, height: 0)
        self.notifView = notifView
    }
}

extension DictsViewController: IBottomNotificationViewDelegate {
    func onCancelButtonPressed() {
        self.dataSource.undoLastDeletion()
    }
    
    func onTimerDone() {
        self.dataSource.commitChanges()
    }
    
    
}
