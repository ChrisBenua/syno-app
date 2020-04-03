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

protocol ITestControllerState {
    var itemNumber: Int { get set }
    var answers: [[ITestControllerAnswer]] { get set }
}

class TestControllerState: ITestControllerState {
    var itemNumber: Int
    
    var answers: [[ITestControllerAnswer]]
    
    init() {
        itemNumber = 0
        answers = []
    }
    
    init(itemNumber: Int, answers: [[ITestControllerAnswer]]) {
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

protocol ITestViewControllerDataProvider {
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
    
    private var translatedWords: [UserCardForTestViewController]
    
    init(sourceDictionary: DbUserDictionary) {
        self.count = sourceDictionary.getCards().count
        self.translatedWords = sourceDictionary.getCards().map({ (card) -> UserCardForTestViewController in
            return UserCardForTestViewController.initFrom(card: card)
        })
        self.dictName = sourceDictionary.name
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
            
        }
        
        removeAction.image = #imageLiteral(resourceName: "criss-cross")
        
        removeAction.backgroundColor = UIColor(red: 240.0/255, green: 240.0/255, blue: 240.0/255, alpha: 1.0)
        let config = UISwipeActionsConfiguration(actions: [removeAction])
        config.performsFirstActionWithFullSwipe = false
        return config
    }
    
    func onAddLineForAnswer() {
        self.state.answers[state.itemNumber].append(TestControllerAnswer(answer: ""))
        reactor?.addItems(indexPaths: [IndexPath(row: self.state.answers[self.state.itemNumber].count - 1, section: 0)])
    }
    
    func onDeleteLineForAnswer(sender: UITableViewCell) {
        let indexPath = reactor!.tableView.indexPath(for: sender)!
        self.state.answers[self.state.itemNumber].remove(at: indexPath.row)
        reactor?.deleteItems(indexPaths: [indexPath])
    }
    
    func textDidChange(sender: UITableViewCell, text: String?) {
        let indexPath = reactor!.tableView.indexPath(for: sender)!
        self.state.answers[self.state.itemNumber][indexPath.row].answer = text ?? ""
    }
    
    init(state: ITestControllerState, dataProvider: ITestViewControllerDataProvider) {
        self.state = state
        self.dataProvider = dataProvider
    }
}

protocol ITestViewControllerModel {
    var dataSource: ITestViewControllerDataSource { get }
}

class TestViewControllerModel: ITestViewControllerModel {
    var dataSource: ITestViewControllerDataSource
    
    init(dataSource: ITestViewControllerDataSource) {
        self.dataSource = dataSource
    }
}
