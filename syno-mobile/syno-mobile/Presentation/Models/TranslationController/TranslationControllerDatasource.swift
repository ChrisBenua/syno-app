import Foundation
import CoreData
import UIKit

/// Protocol for delivering data to table view with translations
protocol ITranslationControllerDataProvider {
    /// Card which translations instance delivers
    var sourceCard: DbUserCard { get set }
    /// Gets all translations from this card
    func getTranslations() -> [ITranslationCellConfiguration]
    /// Updates translation at given position
    func updateAt(ind: Int, newTranslation: ITranslationCellConfiguration)
    /// Adds new translation
    func add()
    /// Deletes tranlation at given position
    func deleteAt(ind: Int)
    /// Performes save
    func performSave(completionHandler: (() -> ())?)
    /// Updates card's translated word
    func updateTranslatedWord(translatedWord: String?)
    /// Deletes temporary card
    func deleteTempCard(completionHandler: (() -> Void)?)
}

protocol ITranslationControllerDataSource: UITableViewDataSource, UITableViewDelegate, ITranslationCellDidChangeDelegate {
    /// Service for data delivery
    var viewModel: ITranslationControllerDataProvider { get }
    /// updates translation at given position
    func updateAt(ind: Int, newTranslation: ITranslationCellConfiguration)
    /// Add new translation
    func add()
    /// Deletes translation at given position
    func deleteAt(ind: Int)
    /// Performes save
    func save(completionHandler: (() -> ())?)
    /// Updates card's translated word
    func updateTranslatedWord(newTranslatedWord: String?)
    
    //for new card controller
    /// Deletes temporary card
    func deleteTempCard(completionHandler: (() -> Void)?)
}

/// `DbTranslation` dto
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
    
    /// Inner instance of `ITranslationCellConfiguration`; `sample`, `comment`, `transcription` and `translation` properties are delegated to this
    var translationCellConfiguration: ITranslationCellConfiguration
    /// `CoreData` object ID
    var transObjectID: NSManagedObjectID?
    
    /**
     Creates new `TranslationCellWrapper`
     - Parameter translation: inner instance of `ITranslationCellConfiguration`
     - Parameter objectId: `CoreData` translations object ID
     */
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
        }/*.sorted(by: { (lhs, rhs) -> Bool in
            return (lhs.translation ?? "") < (rhs.translation ?? "")
        })*/
        
        return translations!
    }
    
    func updateAt(ind: Int, newTranslation: ITranslationCellConfiguration) {
        let trans = self.translations![ind]
        trans.comment = newTranslation.comment?.trimmingCharacters(in: .whitespacesAndNewlines)
        trans.sample = newTranslation.sample?.trimmingCharacters(in: .whitespacesAndNewlines)
        trans.transcription = newTranslation.transcription?.trimmingCharacters(in: .whitespacesAndNewlines)
        trans.translation = newTranslation.translation?.trimmingCharacters(in: .whitespacesAndNewlines)
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
    
    /// Updated card's translated word
    private var newTranslatedWord: String?
    
    /// Card;s translation DTOs
    private var translations: [TranslationCellWrapper]?
    
    /// Source card
    private var _sourceCard: DbUserCard!
    
    /// Translations object IDs which should be deleted
    private var shouldDeleteTransObjectIds: [NSManagedObjectID] = []
    
    public var sourceCard: DbUserCard {
        get {
            return _sourceCard
        } set {
            _sourceCard = newValue
        }
    }
    /// Service for performing actions with CoreData
    private var storageCoordinator: IStorageCoordinator

    /**
     Create new `TranslationControllerDataProvider`
     - Parameter storageCoordinator: Service for performing actions with CoreData
     */
    init(storageCoordinator: IStorageCoordinator) {
        self.storageCoordinator = storageCoordinator
    }
}

/// table view cell's event listener
protocol ITranslationCellDidChangeDelegate: class {
    /// Updates state in dataSource
    func update(caller: UITableViewCell, newConf: ITranslationCellConfiguration)
    
    /// Generates transcription for given word
    func getTranscription(for word: String) -> String?
    
    /// Sets last user's focused point
    func setLastFocusedPoint(point: CGPoint,sender: UIView)
    
    /// Notifies when user ended editing card
    func didEndEditing()
    
    /// Gets last focused point
    func getLastFocusedPoint() -> CGPoint?
    
    var tableView: UITableView! { get set }
    
    func addOneTranslationIfNeeded()
    
    var didChange: Bool { get }
}

class TranslationControllerDataSource: NSObject, ITranslationControllerDataSource {
    /// Stores real heights for cells
    var cellHeights: [IndexPath: CGFloat] = [:]
    
    var didAddNewTranslation: Bool = false
    
    var didChange = false
    
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
        didChange = true
        self.viewModel.updateAt(ind: ind, newTranslation: newTranslation)
    }
    
    func add() {
        didChange = true
        didAddNewTranslation = true
        self.viewModel.add()
        //UIView.performWithoutAnimation {
            self.tableView.reloadData()
        //}
    }
    
    func deleteAt(ind: Int) {
        didChange = true
        didAddNewTranslation = false
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
        if self.didAddNewTranslation && indexPath.row == 0 {
            self.didAddNewTranslation = false
            let myCell = cell as! TranslationTableViewCell
            myCell.innerView.baseShadowView.alpha = 0
            UIView.animate(withDuration: 0.5) {
                myCell.innerView.baseShadowView.alpha = 1
            }
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeights[indexPath] ?? 300
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.tableView = tableView
        return items.count
    }
    
    @available(iOS 13.0, *)
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: indexPath as NSCopying, previewProvider: nil) { (_) -> UIMenu? in
            let menu = UIMenu(title: "Действия", children: [
                UIAction(title: "Удалить", image: UIImage.init(systemName: "trash.fill"), attributes: .destructive, handler: { (action) in
                    UIView.animate(withDuration: 0, delay: 0.5, animations: { () in }) { (_) in
                        self.deleteAt(ind: indexPath.row)
                    }
                })
            ])
            return menu
        }
    }
    
    @available(iOS 13.0, *)
    func tableView(_ tableView: UITableView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        return makeTargetedPreview(tableView: tableView, for: configuration)
    }
    @available(iOS 13.0, *)
    func tableView(_ tableView: UITableView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        return makeTargetedPreview(tableView: tableView, for: configuration)
    }
    
    @available(iOS 13.0, *)
    private func makeTargetedPreview(tableView: UITableView, for configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        guard let indexPath = configuration.identifier as? IndexPath else { return nil }
        // Get the cell for the index of the model
        guard let cell = tableView.cellForRow(at: indexPath) as? TranslationTableViewCell else { return nil }
        // Set parameters to a circular mask and clear background
        let parameters = UIPreviewParameters()
        parameters.visiblePath = UIBezierPath(roundedRect: cell.innerView.baseShadowView.containerView.bounds, cornerRadius: 20)
        parameters.backgroundColor = .clear

        // Return a targeted preview using our cell previewView and parameters
        return UITargetedPreview(view: cell.innerView.baseShadowView.containerView, parameters: parameters)
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
    
    /// Bottom point of view that was focused by user
    private var lastFocusedPoint: CGPoint?
    
    /// Service for generating transcriptions
    private var phonemesManager: IPhonemesManager
    
    /// Updating scrolling position of controller
    weak var controllerDelegate: IScrollableToPoint?
    
    /// If auto generating of transcription enabled
    private var isAutoPhonemesEnabled: Bool
    
    /// Gets translations DTOs
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
    
    func addOneTranslationIfNeeded() {
        if (self.viewModel.getTranslations().count == 0) {
            self.add()
        }
    }
    
    /**
     Creates new `TranslationControllerDataSource`
     - Parameter viewModel: Service for data delivery
     - Parameter sourceCard: Source card
     - Parameter phonemesManager: Service for generating transcriptions
     - Parameter isAutoPhonemesEnabled: Should generate transcriptions automatically
     */
    init(viewModel: ITranslationControllerDataProvider, sourceCard: DbUserCard, phonemesManager: IPhonemesManager, isAutoPhonemesEnabled: Bool = true) {
        self.viewModel = viewModel
        self.viewModel.sourceCard = sourceCard
        self.phonemesManager = phonemesManager
        self.isAutoPhonemesEnabled = isAutoPhonemesEnabled
        super.init()
    }
}

