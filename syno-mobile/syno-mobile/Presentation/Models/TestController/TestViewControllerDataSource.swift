//
//  TestViewControllerDataSource.swift
//  syno-mobile
//
//  Created by Ирина Улитина on 05.01.2020.
//  Copyright © 2020 Christian Benua. All rights reserved.
//

import Foundation
import UIKit

protocol ITestControllerAnswer {
    var answer: String { get set }
}

class TestControllerAnswer: ITestControllerAnswer {
    var answer: String
    
    init(answer: String) {
        self.answer = answer
    }
}

class AnswersStorage {
    var answers: [[ITestControllerAnswer]]
    
    subscript(index: Int) -> [ITestControllerAnswer] {
        return answers[index]
    }
    
    subscript(index1: Int, index2: Int) -> ITestControllerAnswer {
        return answers[index1][index2]
    }
    
    func append(pos: Int, answer: ITestControllerAnswer) {
        self.answers[pos].append(answer)
    }
    
    func remove(pos1: Int, pos2: Int) {
        self.answers[pos1].remove(at: pos2)
    }
    
    func setAnswer(pos1: Int, pos2: Int, answer: String) {
        self.answers[pos1][pos2].answer = answer
    }
    
    init(answers: [[ITestControllerAnswer]]) {
        self.answers = answers
    }
}

protocol ITestControllerState {
    var itemNumber: Int { get set }
    var answers: AnswersStorage { get set }
}

class TestControllerState: ITestControllerState {
    var itemNumber: Int
    
    var answers: AnswersStorage
    
    init() {
        itemNumber = 0
        answers = AnswersStorage(answers: [])
    }
    
    init(itemNumber: Int, answers: AnswersStorage) {
        self.itemNumber = itemNumber
        self.answers = answers
    }
}

protocol ITestViewControllerTableViewCellReactor: class {
    func onAddLineForAnswer()
    
    func onDeleteLineForAnswer(sender: UITableViewCell)
}


protocol IUserCardForTestViewController {
    var translatedWord: String? { get }
    var translationsCount: Int { get }
}

class UserCardForTestViewController: IUserCardForTestViewController {
    var translatedWord: String?
    var translationsCount: Int
    
    init(translatedWord: String?, translationsCount: Int) {
        self.translatedWord = translatedWord
        self.translationsCount = translationsCount
    }
    
    static func initFrom(card: DbUserCard) -> UserCardForTestViewController {
        return UserCardForTestViewController(translatedWord: card.translatedWord, translationsCount: card.getTranslations().count)
    }
}

protocol ITestViewControllerCoreDataHandler {
    func initializeCoreDataTest()
    
    func cancelTest(completionBlock: (() -> ())?)
    
    func saveCoreDataTest(answers: AnswersStorage,completionBlock: ((DbUserTest) -> ())?)
}

protocol ITestViewControllerDataProvider: ITestViewControllerCoreDataHandler {
    func getItem(cardPos: Int) -> UserCardForTestViewController
    var count: Int { get }
    var dictName: String? { get }
}


class TestViewControllerDataProvider: ITestViewControllerDataProvider {
    func getItem(cardPos: Int) -> UserCardForTestViewController {
        return translatedWords[cardPos]
    }
    
    var count: Int
    
    var dictName: String?
        
    private var sourceDict: DbUserDictionary
    
    private var cards: [DbUserCard]
    
    private var translatedWords: [UserCardForTestViewController]
    
    private var dbUserTest: DbUserTest!
    
    private var storageManager: IStorageCoordinator
    
    private var dispatchGroup = DispatchGroup()
    
    func initializeCoreDataTest() {
        dbUserTest = DbUserTest.createUserTestFor(context: self.storageManager.stack.mainContext, dict: self.sourceDict)
        dispatchGroup.enter()
        self.storageManager.stack.performSave(with: self.storageManager.stack.mainContext) {
            self.dispatchGroup.leave()
        }
    }
    
    func cancelTest(completionBlock: (() -> ())?) {
        self.storageManager.stack.mainContext.delete(dbUserTest)
        self.storageManager.stack.performSave(with: self.storageManager.stack.mainContext, completion: completionBlock)
    }
    
    func saveCoreDataTest(answers: AnswersStorage, completionBlock: ((DbUserTest) -> ())?) {
        DispatchQueue.global(qos: .background).async {
            self.dispatchGroup.wait()
            
            print(self.dbUserTest.objectID)
            self.storageManager.stack.mainContext.performAndWait {
                for dbTestCard in self.dbUserTest.testDict!.getCards() {
                    let ind = self.cards.firstIndex(of: dbTestCard.sourceCard!)!
                    
                    let currCardAnswers = answers[ind]
                    
                    let transArr = dbTestCard.getTranslations()
                    
                    for dbTranlsation in transArr {
                        if (currCardAnswers.filter({ (answer) -> Bool in
                            return dbTranlsation.translation!.lowercased() == answer.answer.lowercased().trimmingCharacters(in: .whitespaces)
                            }).count > 0) {
                            dbTranlsation.isRightAnswered = true
                        }
                    }
                }
            }
            
            self.dbUserTest.endTest()
            
            
            self.storageManager.stack.performSave(with: self.storageManager.stack.mainContext) {
                completionBlock?(self.dbUserTest)
            }
        }
    }
    
    init(sourceDictionary: DbUserDictionary, storageManager: IStorageCoordinator) {
        self.storageManager = storageManager
        self.sourceDict = sourceDictionary
        self.cards = sourceDictionary.getCards()
        self.count = self.cards.count
        self.translatedWords = self.cards.map({ (card) -> UserCardForTestViewController in
            return UserCardForTestViewController.initFrom(card: card)
        })
        self.dictName = sourceDictionary.name
        initializeCoreDataTest()
    }
}


protocol ITestViewControllerDataSource: UITableViewDataSource, UITableViewDelegate, ITestViewControllerTableViewCellReactor, ITestControllerTranslationCellDelegate {
    var state: ITestControllerState { get }
    var dataProvider: ITestViewControllerDataProvider { get }
    var reactor: ITestViewControllerDataSourceReactor? { get set }
    var onFocusedLabelDelegate: IScrollableToPoint? { get set }
}

protocol ITestViewControllerDataSourceReactor: class {
    func addItems(indexPaths: [IndexPath])
    func deleteItems(indexPaths: [IndexPath])
    
    var tableView: UITableView { get }
}

protocol ITextFieldTestControllerEditingDelegate: class {
    func beginEditingInCell(cell: UITableViewCell)
    
    func endEditingInCell(cell: UITableViewCell)
}

class TestViewControllerDataSource: NSObject, ITestViewControllerDataSource, ITextFieldTestControllerEditingDelegate {
    var state: ITestControllerState
    var dataProvider: ITestViewControllerDataProvider
    weak var reactor: ITestViewControllerDataSourceReactor?
    weak var onFocusedLabelDelegate: IScrollableToPoint?
    
    func endEditingInCell(cell: UITableViewCell) {
        print("ednediting")
        onFocusedLabelDelegate?.scrollToTop()
    }
        
    func beginEditingInCell(cell: UITableViewCell) {
        let rect = reactor!.tableView.rectForRow(at: reactor!.tableView.indexPath(for: cell)!)
        onFocusedLabelDelegate?.scrollToPoint(point: CGPoint(x: rect.origin.x, y: rect.origin.y + rect.width))
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return state.answers[self.state.itemNumber].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TestControllerTranslationTableViewCell.cellId, for: indexPath) as? TestControllerTranslationTableViewCell else {
            fatalError()
        }
        cell.delegate = self
        cell.editingDelegate = self
        cell.setup(config: TestControllerTranslationCellConfiguration(translation: state.answers[state.itemNumber][indexPath.row].answer))
        return cell
    }

    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let removeAction = UIContextualAction(style: .normal, title: "Remove") { (action, view, _) in
            if let cell = tableView.cellForRow(at: indexPath) {
                self.onDeleteLineForAnswer(sender: cell)
            }
        }
        
        removeAction.image = #imageLiteral(resourceName: "criss-cross")
        
        removeAction.backgroundColor = UIColor(red: 240.0/255, green: 240.0/255, blue: 240.0/255, alpha: 1.0)
        let config = UISwipeActionsConfiguration(actions: [removeAction])
        config.performsFirstActionWithFullSwipe = false
        return config
    }
    
    func onAddLineForAnswer() {
        self.state.answers.append(pos: state.itemNumber, answer: TestControllerAnswer(answer: ""))
        reactor?.addItems(indexPaths: [IndexPath(row: self.state.answers[self.state.itemNumber].count - 1, section: 0)])
    }
    
    func onDeleteLineForAnswer(sender: UITableViewCell) {
        let indexPath = reactor!.tableView.indexPath(for: sender)!
        self.state.answers.remove(pos1: self.state.itemNumber, pos2: indexPath.row)
        reactor?.deleteItems(indexPaths: [indexPath])
    }
    
    func textDidChange(sender: UITableViewCell, text: String?) {
        let indexPath = reactor!.tableView.indexPath(for: sender)!
        self.state.answers.setAnswer(pos1: self.state.itemNumber, pos2: indexPath.row, answer: text ?? "")
    }
    
    init(state: ITestControllerState, dataProvider: ITestViewControllerDataProvider) {
        self.state = state
        self.dataProvider = dataProvider
    }
}

protocol ITestViewControllerModel {
    var dataSource: ITestViewControllerDataSource { get }
    
    func endTest(completionBlock: ((DbUserTest) -> ())?)
    
    func cancelTest(completionBlock: (() -> ())?)
}

class TestViewControllerModel: ITestViewControllerModel {
    var dataSource: ITestViewControllerDataSource
    
    func endTest(completionBlock: ((DbUserTest) -> ())?) {
        self.dataSource.dataProvider.saveCoreDataTest(answers: self.dataSource.state.answers, completionBlock: completionBlock)
    }
    
    func cancelTest(completionBlock: (() -> ())?) {
        self.dataSource.dataProvider.cancelTest(completionBlock: completionBlock)
    }
    
    init(dataSource: ITestViewControllerDataSource) {
        self.dataSource = dataSource
    }
}
