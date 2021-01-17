//
//  DictsSearchControllerDataSource.swift
//  syno-mobile
//
//  Created by Christian Benua on 17.01.2021.
//  Copyright © 2021 Christian Benua. All rights reserved.
//

import Foundation
import UIKit
import CoreData

struct DictsSearchControllerState {
    var searchMode: Mode
    var searchString: String
    
    enum Mode: CaseIterable {
        case dicts
        case cards
    }
}

protocol IDictsSearchControllerModel: IDictsSearchControllerDataSourceReactor {
    var delegate: DictsSearchControllerModelDelegate? { get set }
    var state: DictsSearchControllerState { get }
    var dataSource: IDictsSearchControllerDataSource { get }
    
    func fetch()
    func updateState(searchString: String, mode: Int, doFetch: Bool)
}

protocol IDictsSearchControllerDataSource: class, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    var reactor: IDictsSearchControllerDataSourceReactor? { get set }
    
    func fetch(state: DictsSearchControllerState)
}

protocol DictsSearchControllerModelDelegate: class {
    func showController(controller: UIViewController, completion: ((UIViewController) -> Void)?)
    
    func onShowSharingProcessView()
    
    func onShowSharingResultView(result: ShowSharingResultViewConfiguration)
}

protocol IDictsSearchControllerDataSourceReactor: class {
    func onSelectedCard(card: DbUserCard)
    
    func onSelectedDictionary(dictionary: DbUserDictionary)
    
    func onHandleEdit(dictionary: DbUserDictionary)
    
    func onStartedSharing()
    
    func onSharingCompleted(result: ShowSharingResultViewConfiguration)
}

protocol IDictsSearchControllerDataProvider {
    func fetch(state: DictsSearchControllerState)
    
    var dictsResults: [DbUserDictionary] { get }
    var cardResults: [String: [DbUserCard]] { get }
    var sortedKeys: [String] { get }
}


//TODO: caching?
class DictsSearchControllerDataProviderImpl: IDictsSearchControllerDataProvider {
    private var storageManager: IStorageCoordinator
    
    var dictsResults: [DbUserDictionary] = []
    var cardResults: [String: [DbUserCard]] = [:]
    
    var sortedKeys: [String] {
        return cardResults.keys.sorted()
    }
    
    func fetch(state: DictsSearchControllerState) {
        let mainContext = storageManager.stack.mainContext
        mainContext.performAndWait {
            if let currentAppUser = storageManager.getCurrentAppUser() {
                if (state.searchMode == .dicts) {
                    dictsResults = try! mainContext.fetch(DbUserDictionary.requestFilteredSortedByName(owner: currentAppUser, searchText: state.searchString))
                } else if (state.searchMode == .cards) {
                    let results = (try! mainContext.fetch(DbUserCard.requestAllCardsWith(owner: currentAppUser)))
                        .filter({ (card) -> Bool in
                            let translatedWord = card.translatedWord ?? ""
                            return translatedWord.lowercased().starts(with: state.searchString.lowercased()) || (card.getTranslations().filter({ (trans) -> Bool in
                                return (trans.translation ?? "").lowercased().starts(with: state.searchString.lowercased())
                            }).count > 0)
                        })
                    cardResults = Dictionary.init(grouping: results) { (res) -> String in
                        res.sourceDictionary?.name ?? ""
                    }
                }
            }
        }
    }

    init(storageManager: IStorageCoordinator) {
        self.storageManager = storageManager
    }
}

class DictsSearchControllerDataSourceImpl: NSObject, IDictsSearchControllerDataSource {
    weak var reactor: IDictsSearchControllerDataSourceReactor?
    private var dataProvider: IDictsSearchControllerDataProvider
    private var state: DictsSearchControllerState!
    private var shareService: IDictShareService
    
    func fetch(state: DictsSearchControllerState) {
        self.state = state
        self.dataProvider.fetch(state: state)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.state.searchMode == .dicts ? 1 : self.dataProvider.cardResults.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let keys = self.dataProvider.sortedKeys
        let count = self.state.searchMode == .dicts ? self.dataProvider.dictsResults.count : self.dataProvider.cardResults[keys[section]]!.count
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if self.state.searchMode == .dicts {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DictionaryCollectionViewCell.cellId, for: indexPath) as? DictionaryCollectionViewCell else {
                fatalError()
            }
            cell.setup(config: self.dataProvider.dictsResults[indexPath.row].toUserDictCellConfig())
            return cell
        } else if self.state.searchMode == .cards {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CardCollectionViewCell.cellId, for: indexPath) as? CardCollectionViewCell else {
                fatalError()
            }
            let keys = self.dataProvider.sortedKeys
            cell.setup(configuration: self.dataProvider.cardResults[keys[indexPath.section]]![indexPath.row].toCellConfiguration(), textToHighlight: self.state.searchString.lowercased())
            return cell
        }
        return UICollectionViewCell()
    }
    
    func handleShare(dictionary: DbUserDictionary) {
        self.reactor?.onStartedSharing()
        self.shareService.createShare(dictObjectID: dictionary.objectID) { (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let str):
                    self.reactor?.onSharingCompleted(result: .success(code: str.code, dictName: dictionary.name ?? ""))
                case .error(let err):
                    self.reactor?.onSharingCompleted(result: .failure(alertTitle: "Ошибка", alertText: err))
                }
            }
        }
    }
    
    func handleEdit(dictionary: DbUserDictionary) {
        self.reactor?.onHandleEdit(dictionary: dictionary)
    }
    
    init(dataProvider: IDictsSearchControllerDataProvider, shareService: IDictShareService) {
        self.dataProvider = dataProvider
        self.shareService = shareService
    }
}

extension DictsSearchControllerDataSourceImpl {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if self.state.searchMode == .dicts {
            return CGSize(width: collectionView.frame.width / 2 - 20, height: 100)
        } else {
            return CGSize(width: collectionView.frame.width - 30, height: 46)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.state.searchMode == .cards {
            self.reactor?.onSelectedCard(card: self.dataProvider.cardResults[self.dataProvider.sortedKeys[indexPath.section]]![indexPath.row])
        } else {
            self.reactor?.onSelectedDictionary(dictionary: self.dataProvider.dictsResults[indexPath.row])
        }
    }
    
    @available(iOS 13.0, *)
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return self.state.searchMode == .dicts ? UIContextMenuConfiguration(identifier: indexPath as NSCopying, previewProvider: nil) { (_) -> UIMenu? in
            let menu = UIMenu(title: "Действия", children: [
                UIAction(title: "Поделиться", image: UIImage.init(systemName: "square.and.arrow.up"), handler: { (action) in
                    self.handleShare(dictionary: self.dataProvider.dictsResults[indexPath.row])
                }),
                UIAction(title: "Редактировать", image: UIImage.init(systemName: "square.and.pencil"), handler: { (action) in
                    self.handleEdit(dictionary: self.dataProvider.dictsResults[indexPath.row])
                })
            ])
            return menu
        } : nil
    }
    
    @available(iOS 13.0, *)
    func collectionView(_ collectionView: UICollectionView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        return self.state.searchMode == .dicts ? makeTargetedPreview(collection: collectionView, for: configuration) : nil
    }

    @available(iOS 13.0, *)
    func collectionView(_ collectionView: UICollectionView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        return self.state.searchMode == .dicts ? makeTargetedPreview(collection: collectionView, for: configuration) : nil
    }

    @available(iOS 13.0, *)
    private func makeTargetedPreview(collection: UICollectionView, for configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        guard let indexPath = configuration.identifier as? IndexPath else { return nil }
        // Get the cell for the index of the model
        guard let cell = collection.cellForItem(at: indexPath) as? DictionaryCollectionViewCell else { return nil }
        // Set parameters to a circular mask and clear background
        let parameters = UIPreviewParameters()
        
        return UITargetedPreview(view: cell.baseShadowView.containerView, parameters: parameters)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: DictsSearchDictNameHeader.headerId, for: indexPath)
        (header as? DictsSearchDictNameHeader)?.dictionaryNameLabel.text = self.dataProvider.cardResults.keys.sorted()[indexPath.section]
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if self.state.searchMode == .cards && self.dataProvider.cardResults.count > 0 {
            return CGSize(width: collectionView.frame.width, height: 39)
        }
        return CGSize.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
        
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return self.state.searchMode == .dicts ? 15 : 5
    }
}

class DictsSearchControllerModelImpl: IDictsSearchControllerModel {
    private var presentationAssembly: IPresentationAssembly
    
    weak var delegate: DictsSearchControllerModelDelegate?
    var state: DictsSearchControllerState = DictsSearchControllerState(searchMode: .dicts, searchString: "")
    var dataSource: IDictsSearchControllerDataSource
    
    func fetch() {
        self.dataSource.fetch(state: self.state)
    }
    
    func updateState(searchString: String, mode: Int, doFetch: Bool = true) {
        Logger.log("SearchString: \(searchString)")
        self.state.searchString = searchString
        self.state.searchMode = DictsSearchControllerState.Mode.allCases[mode]
        
        if doFetch {
            self.fetch()
        }
    }
    
    func onSelectedCard(card: DbUserCard) {
        self.delegate?.showController(controller: self.presentationAssembly.cardsViewController(sourceDict: card.sourceDictionary!), completion: { (controller) in
            controller.navigationController?.pushViewController(self.presentationAssembly.translationsViewController(sourceCard: card), animated: true)
        })
    }
    
    func onSelectedDictionary(dictionary: DbUserDictionary) {
        self.delegate?.showController(controller: self.presentationAssembly.cardsViewController(sourceDict: dictionary), completion: nil)
    }
    
    func onStartedSharing() {
        self.delegate?.onShowSharingProcessView()
    }
    
    func onSharingCompleted(result: ShowSharingResultViewConfiguration) {
        self.delegate?.onShowSharingResultView(result: result)
    }
    
    func onHandleEdit(dictionary: DbUserDictionary) {
        self.delegate?.showController(controller: self.presentationAssembly.editDictController(dictToEdit: dictionary), completion: nil)
    }
    
    init(dataSource: IDictsSearchControllerDataSource, presentationAssembly: IPresentationAssembly) {
        self.dataSource = dataSource
        self.presentationAssembly = presentationAssembly
        self.dataSource.reactor = self
    }
}

