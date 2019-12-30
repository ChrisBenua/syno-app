//
//  LearnControllerTableViewDataSource.swift
//  syno-mobile
//
//  Created by Ирина Улитина on 20.12.2019.
//  Copyright © 2019 Christian Benua. All rights reserved.
//

import Foundation
import UIKit

protocol ILearnControllerState {
    var itemNumber: Int { get set }
    var translationsShown: Int { get set }
}


class LearnControllerState: ILearnControllerState {
    private var _itemNumber: Int = 0
    var translationsShown: Int = 0
    
    init() {
        _itemNumber = 0
    }
    
    init(itemNumber: Int) {
        self._itemNumber = itemNumber
    }
    
    var itemNumber: Int {
        get {
            _itemNumber
        }
        set {
            _itemNumber = newValue
            translationsShown = 0
        }
    }
}

protocol ILearnControllerDataProvider {
    func getItem(cardPos: Int, transPos: Int) -> UserTranslationDtoForLearnController
    func getItems(currCardPos: Int) -> [UserTranslationDtoForLearnController]
    func getTranslatedWord(cardPos: Int) -> String?
    var count: Int { get }
    var dictName: String? { get }
}

class LearnControllerDataProvider: ILearnControllerDataProvider {
    func getTranslatedWord(cardPos: Int) -> String? {
        return translatedWords[cardPos]
    }
    
    func getItem(cardPos: Int, transPos: Int) -> UserTranslationDtoForLearnController {
        return itemsInCards[cardPos][transPos]
    }
    
    func getItems(currCardPos: Int) -> [UserTranslationDtoForLearnController] {
        return itemsInCards[currCardPos]
    }
    
    var count: Int {
        get {
            return itemsInCards.count
        }
    }
    
    private var itemsInCards: [[UserTranslationDtoForLearnController]]
    private var translatedWords: [String?]
    
    var dictName: String?
    
    init(dbUserDict: DbUserDictionary) {
        self.dictName = dbUserDict.name
        self.translatedWords = dbUserDict.getCards().map({ (card) -> String? in
            card.translatedWord
        })
        self.itemsInCards = dbUserDict.getCards().map({ (card) -> [UserTranslationDtoForLearnController] in
            return card.getTranslations().map { (trans) -> UserTranslationDtoForLearnController in
                return UserTranslationDtoForLearnController.initFrom(translation: trans)
            }
        })
    }
}

protocol ILearnControllerTableViewDataSource: UITableViewDataSource, UITableViewDelegate, ILearnControllerActionsDelegate {
    var viewModel: ILearnControllerDataProvider { get }
    var state: ILearnControllerState { get }
    var delegate: ILearnControllerDataSourceReactor? { get set }
}

protocol ILearnControllerActionsDelegate: class {
    func onPlusOne()
    func onShowAll()
    //func onNext()
    //func onPrev()
}

protocol ILearnControllerDataSourceReactor: class {
    //func reload()
    func addItems(indexPaths: [IndexPath])
}

class LearnControllerTableViewDataSource: NSObject, ILearnControllerTableViewDataSource {
    
    weak var delegate: ILearnControllerDataSourceReactor?
    
    var viewModel: ILearnControllerDataProvider
    
    var state: ILearnControllerState
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return state.translationsShown
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TranslationReadonlyTableViewCell.cellId(), for: indexPath) as? TranslationReadonlyTableViewCell else {
            fatalError()
        }
        let transDto = self.viewModel.getItem(cardPos: self.state.itemNumber, transPos: indexPath.row)
        
        cell.setup(config: TranslationCellConfiguration(translation: transDto.translation, transcription: transDto.transcription, comment: transDto.comment, sample: transDto.sample))
        
        return cell
    }
    
    init(viewModel: ILearnControllerDataProvider) {
        self.viewModel = viewModel
        self.state = LearnControllerState()
    }
    
    init(viewModel: ILearnControllerDataProvider, state: ILearnControllerState) {
        self.viewModel = viewModel
        self.state = state
    }
    
    func onPlusOne() {
        if (self.state.translationsShown < self.viewModel.getItems(currCardPos: self.state.itemNumber).count) {
            self.state.translationsShown += 1
            self.delegate?.addItems(indexPaths: [IndexPath(row: self.state.translationsShown - 1, section: 0)])
        }
    }
    
    func onShowAll() {
        let items = (self.state.translationsShown..<self.viewModel.getItems(currCardPos: self.state.itemNumber).count).map { (row) -> IndexPath in
            return IndexPath(row: row, section: 0)
        }
        
        self.state.translationsShown = self.viewModel.getItems(currCardPos: self.state.itemNumber).count
        delegate?.addItems(indexPaths: items)
    }
    
//    func onNext() {
//        self.state.itemNumber += 1
//        delegate?.reload()
//    }
//
//    func onPrev() {
//        self.state.itemNumber -= 1
//        delegate?.reload()
//    }
}
