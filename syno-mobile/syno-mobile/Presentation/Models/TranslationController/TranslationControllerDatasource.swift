//
//  TranslationControllerDatasource.swift
//  syno-mobile
//
//  Created by Ирина Улитина on 13.12.2019.
//  Copyright © 2019 Christian Benua. All rights reserved.
//

import Foundation
import CoreData
import UIKit


protocol ITranslationControllerDataProvider {
    var sourceCard: DbUserCard { get set }
    func getTranslations() -> [ITranslationCellConfiguration]
    func updateAt(ind: Int, newTranslation: ITranslationCellConfiguration)
    func add()
    func deleteAt(ind: Int)
    func performSave(completionHandler: (() -> ())?)
}

protocol ITranslationControllerDataSource: UITableViewDataSource, UITableViewDelegate, ITranslationCellDidChangeDelegate {
    
    var viewModel: ITranslationControllerDataProvider { get }
    func updateAt(ind: Int, newTranslation: ITranslationCellConfiguration)
    func add()
    func deleteAt(ind: Int)
    func save(completionHandler: (() -> ())?)
}


class TranslationCellWrapper: ITranslationCellConfiguration {
    var translation: String? {
        get {
            return self.translationCellConfiguration.translation
        }
        set (newValue) {
            self.translationCellConfiguration.translation = newValue
        }
    }
    
    var transcription: String? {
        get {
            return self.translationCellConfiguration.transcription
        }
        set (newValue) {
            self.translationCellConfiguration.transcription = newValue
        }
    }
    
    var comment: String? {
        get {
            return self.translationCellConfiguration.comment
        }
        set (newValue) {
            self.translationCellConfiguration.comment = newValue
        }
    }
    
    var sample: String? {
        get {
            return self.translationCellConfiguration.sample
        }
        set (newValue) {
            self.translationCellConfiguration.sample = newValue
        }
    }
    
    var translationCellConfiguration: ITranslationCellConfiguration
    var transObjectID: NSManagedObjectID?
    
    init(translation: ITranslationCellConfiguration, objectId: NSManagedObjectID?) {
        self.translationCellConfiguration = translation
        self.transObjectID = objectId
    }
}

class TranslationControllerDataProvider: ITranslationControllerDataProvider {
    func getTranslations() -> [ITranslationCellConfiguration] {
        if let res = translations {
            return res
        }
        
        let res = self._sourceCard.getTranslations()
        
        translations = res.map { (trans) -> TranslationCellWrapper in
            return TranslationCellWrapper(translation: trans.toTranslationCellConfig(), objectId: trans.objectID)
        }
        
        return translations!
    }
    
    func updateAt(ind: Int, newTranslation: ITranslationCellConfiguration) {
        let trans = self.translations![ind]
        trans.comment = newTranslation.comment
        trans.sample = newTranslation.sample
        trans.transcription = newTranslation.transcription
        trans.translation = newTranslation.translation
    }
    
    func add() {
        self.translations?.append(TranslationCellWrapper(translation: TranslationCellConfiguration(translation: "", transcription: "", comment: "", sample: ""), objectId: nil))
    }
    
    func deleteAt(ind: Int) {
        if let objId = self.translations![ind].transObjectID {
            self.shouldDeleteTransObjectIds.append(objId)
        }
    }
    
    func performSave(completionHandler: (() -> ())?) {
        DispatchQueue.global(qos: .background).async {
            self.storageCoordinator.stack.mainContext.performAndWait {
                for trans in self.translations ?? [] {
                    if let objId = trans.transObjectID {
                        let dbTranslation = self.storageCoordinator.stack.mainContext.object(with: objId) as! DbTranslation
                        dbTranslation.comment = trans.comment
                        dbTranslation.transcription = trans.transcription
                        dbTranslation.translation = trans.translation
                        dbTranslation.usageSample = trans.sample
                    } else {
                        let dbTranslation = DbTranslation.insertTranslation(into: self.storageCoordinator.stack.mainContext)
                        dbTranslation?.comment = trans.comment
                        dbTranslation?.transcription = trans.transcription
                        dbTranslation?.translation = trans.translation
                        dbTranslation?.usageSample = trans.sample
                        dbTranslation?.sourceCard = self._sourceCard
                        dbTranslation?.timeCreated = Date()
                    }
                }
                
                for delObjId in self.shouldDeleteTransObjectIds {
                    let obj = self.storageCoordinator.stack.mainContext.object(with: delObjId)
                    self.storageCoordinator.stack.mainContext.delete(obj)
                }
                
                self.storageCoordinator.stack.performSave(with: self.storageCoordinator.stack.mainContext) {
                    completionHandler?()
                }
            }
        }
    }
    
    private var translations: [TranslationCellWrapper]?
        
    private var _sourceCard: DbUserCard!
    
    private var shouldDeleteTransObjectIds: [NSManagedObjectID] = []
    
    public var sourceCard: DbUserCard {
        get {
            return _sourceCard
        } set {
            _sourceCard = newValue
        }
    }
    
    private var storageCoordinator: IStorageCoordinator

    
    init(storageCoordinator: IStorageCoordinator) {
        self.storageCoordinator = storageCoordinator
    }
}

protocol ITranslationCellDidChangeDelegate: class {
    func update(caller: UITableViewCell, newConf: ITranslationCellConfiguration)
}

class TranslationControllerDataSource: NSObject, ITranslationControllerDataSource {
    func update(caller: UITableViewCell, newConf: ITranslationCellConfiguration) {
        self.updateAt(ind: self.tableView.indexPath(for: caller)!.row, newTranslation: newConf)
    }
    
    func updateAt(ind: Int, newTranslation: ITranslationCellConfiguration) {
        self.viewModel.updateAt(ind: ind, newTranslation: newTranslation)
    }
    
    func add() {
        let cnt = self.viewModel.getTranslations().count
        self.viewModel.add()
        self.tableView.insertRows(at: [IndexPath(row: cnt, section: 0)], with: .automatic)
    }
    
    func deleteAt(ind: Int) {
        self.viewModel.deleteAt(ind: ind)
        self.tableView.deleteRows(at: [IndexPath(row: ind, section: 0)], with: .automatic)
    }
    
    func save(completionHandler: (() -> ())?) {
        self.viewModel.performSave(completionHandler: completionHandler)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.tableView = tableView
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TranslationTableViewCell.cellId(), for: indexPath) as? TranslationTableViewCell else {
            fatalError("Cant cast at \(#function)")
        }
        cell.setup(config: items[indexPath.row])
        cell.delegate = self
        return cell
    }
    
    var viewModel: ITranslationControllerDataProvider
    
    var tableView: UITableView!
    
    var items: [ITranslationCellConfiguration] {
        get {
            return viewModel.getTranslations()
        }
    }
    
    init(viewModel: ITranslationControllerDataProvider, sourceCard: DbUserCard) {
        self.viewModel = viewModel
        self.viewModel.sourceCard = sourceCard
    }
    
}

