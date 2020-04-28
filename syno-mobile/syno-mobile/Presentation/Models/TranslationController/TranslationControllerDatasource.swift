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
    func updateTranslatedWord(translatedWord: String?)
    func deleteTempCard(completionHandler: (() -> Void)?)
}

protocol ITranslationControllerDataSource: UITableViewDataSource, UITableViewDelegate, ITranslationCellDidChangeDelegate {
    
    var viewModel: ITranslationControllerDataProvider { get }
    func updateAt(ind: Int, newTranslation: ITranslationCellConfiguration)
    func add()
    func deleteAt(ind: Int)
    func save(completionHandler: (() -> ())?)
    func updateTranslatedWord(newTranslatedWord: String?)
    //for new card controller
    func deleteTempCard(completionHandler: (() -> Void)?)
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
        self.translations?.insert(TranslationCellWrapper(translation: TranslationCellConfiguration(translation: "", transcription: "", comment: "", sample: ""), objectId: nil), at: 0)
    }
    
    func deleteAt(ind: Int) {
        if let objId = self.translations![ind].transObjectID {
            self.shouldDeleteTransObjectIds.append(objId)
        }
        
        self.translations?.remove(at: ind)
    }
    
    func deleteTempCard(completionHandler: (() -> Void)?) {
        DispatchQueue.global(qos: .background).async {
            let context = self._sourceCard.managedObjectContext!
            context.performAndWait {
                context.delete(self._sourceCard)
            }
            
            self.storageCoordinator.stack.performSave(with: context, completion: completionHandler)
        }
    }
    
    func performSave(completionHandler: (() -> ())?) {
        DispatchQueue.global(qos: .background).async {
            self.storageCoordinator.stack.saveContext.performAndWait {
                let objId = self._sourceCard.objectID
                let card = self.storageCoordinator.stack.saveContext.object(with: objId) as! DbUserCard
                
                if let transWord = self.newTranslatedWord {
                    card.translatedWord = transWord
                }
                
                for trans in self.translations ?? [] {
                    if let objId = trans.transObjectID {
                        let dbTranslation = self.storageCoordinator.stack.saveContext.object(with: objId) as! DbTranslation
                        dbTranslation.comment = trans.comment
                        dbTranslation.transcription = trans.transcription
                        dbTranslation.translation = trans.translation
                        dbTranslation.usageSample = trans.sample
                    } else {
                        let dbTranslation = DbTranslation.insertTranslation(into: self.storageCoordinator.stack.saveContext)
                        dbTranslation?.comment = trans.comment
                        dbTranslation?.transcription = trans.transcription
                        dbTranslation?.translation = trans.translation
                        dbTranslation?.usageSample = trans.sample
                        dbTranslation?.sourceCard = card
                        dbTranslation?.timeCreated = Date()
                    }
                }
                
                for delObjId in self.shouldDeleteTransObjectIds {
                    let obj = self.storageCoordinator.stack.saveContext.object(with: delObjId)
                    self.storageCoordinator.stack.saveContext.delete(obj)
                }
                
                self.storageCoordinator.stack.performSave(with: self.storageCoordinator.stack.saveContext) {
                    completionHandler?()
                }
            }
        }
    }
    
    func updateTranslatedWord(translatedWord: String?) {
        newTranslatedWord = translatedWord
    }
    
    private var newTranslatedWord: String?
    
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
    
    func getTranscription(for word: String) -> String?
    
    func setLastFocusedPoint(point: CGPoint,sender: UIView)
    
    func didEndEditing()
    
    func getLastFocusedPoint() -> CGPoint?
}

class TranslationControllerDataSource: NSObject, ITranslationControllerDataSource {
    
    var cellHeights: [IndexPath: CGFloat] = [:]
    
    func getTranscription(for word: String) -> String? {
        if (isAutoPhonemesEnabled) {
            return self.phonemesManager.getPhoneme(for: word)
        }
        return nil
    }

    func update(caller: UITableViewCell, newConf: ITranslationCellConfiguration) {
        self.updateAt(ind: self.tableView.indexPath(for: caller)!.row, newTranslation: newConf)
    }
    
    func updateAt(ind: Int, newTranslation: ITranslationCellConfiguration) {
        self.viewModel.updateAt(ind: ind, newTranslation: newTranslation)
    }
    
    func add() {
        self.viewModel.add()
        self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
    }
    
    func deleteAt(ind: Int) {
        self.viewModel.deleteAt(ind: ind)
        UIView.performWithoutAnimation {
            self.tableView.reloadData()
        }
    }
    
    func save(completionHandler: (() -> ())?) {
        self.viewModel.performSave(completionHandler: completionHandler)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cellHeights[indexPath] = cell.frame.size.height
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeights[indexPath] ?? 200
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.tableView = tableView
        return items.count
    }
    
    @available(iOS 13.0, *)
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { (_) -> UIMenu? in
            let menu = UIMenu(title: "Actions", children: [
                UIAction(title: "Delete", image: UIImage.init(systemName: "trash.fill"), attributes: .destructive, handler: { (action) in
                    UIView.animate(withDuration: 0, delay: 0.5, animations: { () in }) { (_) in
                        self.deleteAt(ind: indexPath.row)
                    }
                })
            ])
            return menu
        }
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
    
    private var lastFocusedPoint: CGPoint?
    
    private var phonemesManager: IPhonemesManager
    
    weak var controllerDelegate: IScrollableToPoint?
    
    private var isAutoPhonemesEnabled: Bool
    
    var items: [ITranslationCellConfiguration] {
        get {
            return viewModel.getTranslations()
        }
    }
    
    func updateTranslatedWord(newTranslatedWord: String?) {
        self.viewModel.updateTranslatedWord(translatedWord: newTranslatedWord)
    }
    
    func deleteTempCard(completionHandler: (() -> Void)?) {
        self.viewModel.deleteTempCard(completionHandler: completionHandler)
    }
    
    func setLastFocusedPoint(point: CGPoint, sender: UIView) {
        self.lastFocusedPoint = sender.convert(point, to: self.tableView)
    }
    
    func getLastFocusedPoint() -> CGPoint? {
        return lastFocusedPoint
    }
    
    func didEndEditing() {
        self.controllerDelegate?.scrollToTop()
    }
    
    init(viewModel: ITranslationControllerDataProvider, sourceCard: DbUserCard, phonemesManager: IPhonemesManager, isAutoPhonemesEnabled: Bool = true) {
        self.viewModel = viewModel
        self.viewModel.sourceCard = sourceCard
        self.phonemesManager = phonemesManager
        self.isAutoPhonemesEnabled = isAutoPhonemesEnabled
    }
    
}

