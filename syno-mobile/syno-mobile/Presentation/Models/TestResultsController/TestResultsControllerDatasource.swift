//
//  TestResultsControllerDatasource.swift
//  syno-mobile
//
//  Created by Ирина Улитина on 11.04.2020.
//  Copyright © 2020 Christian Benua. All rights reserved.
//

import Foundation
import UIKit

protocol ITestResultsControllerTranslationDto {
    var translation: String? { get }
        
    var isRightAnswered: Bool { get }
}

class TestResultsControllerTranslationDto: ITestResultsControllerTranslationDto {
    var translation: String?
    
    var isRightAnswered: Bool
    
    init(translation: String?, isRightAnswered: Bool) {
        self.translation = translation
        self.isRightAnswered = isRightAnswered
    }
}

protocol ITestResultsControllerCardResultDto {
    var translations: [ITestResultsControllerTranslationDto] { get }
    var translatedWord: String? { get }
}

class TestResultsControllerCardResultsDto: ITestResultsControllerCardResultDto {
    var translations: [ITestResultsControllerTranslationDto]
    var translatedWord: String?
    
    init(translations: [ITestResultsControllerTranslationDto], translatedWord: String?) {
        self.translations = translations
        self.translatedWord = translatedWord
    }
}

protocol ITestResultsControllerTestResult {
    var cardResults: [ITestResultsControllerCardResultDto] { get }
    var dictName: String? { get }
    var percentageScore: Int { get }
}

class TestResultsControllerTestResult: ITestResultsControllerTestResult {
    var percentageScore: Int
    
    var dictName: String?
    
    var cardResults: [ITestResultsControllerCardResultDto]
    
    init(cards: [ITestResultsControllerCardResultDto], dictName: String?, score: Int) {
        self.cardResults = cards
        self.dictName = dictName
        self.percentageScore = score
    }
}

protocol ITestResultsControllerDataProvider {
    func getCardAt(pos: Int) -> ITestResultsControllerCardResultDto
    
    func getTranslationAt(cardPos: Int, transPos: Int) -> ITestResultsControllerTranslationDto
    
    func totalCards() -> Int
    
    func getDictName() -> String?
    
    func getPercentageScore() -> Int
    
    func rightAnsweredAt(pos: Int) -> Int
}

class TestResultsControllerDataProvider: ITestResultsControllerDataProvider {
    func rightAnsweredAt(pos: Int) -> Int {
        return self.testResult.cardResults[pos].translations.map { (translationDto: ITestResultsControllerTranslationDto) -> Int in
            if translationDto.isRightAnswered {
                return 1
            }
            return 0
        }.reduce(0) { (res, new) -> Int in
            return res + new
        }
    }
    
    func getPercentageScore() -> Int {
        return self.testResult.percentageScore
    }
    
    func getDictName() -> String? {
        return self.testResult.dictName
    }
    
    func getCardAt(pos: Int) -> ITestResultsControllerCardResultDto {
        return self.testResult.cardResults[pos]
    }
    
    func getTranslationAt(cardPos: Int, transPos: Int) -> ITestResultsControllerTranslationDto {
        return self.testResult.cardResults[cardPos].translations[transPos]
    }
    
    func totalCards() -> Int {
        return self.testResult.cardResults.count
    }
    
    private var testResult: ITestResultsControllerTestResult
    
    init(test: DbUserTest) {
        let cardsResults: [ITestResultsControllerCardResultDto] = test.testDict!.getCards().map { (dbUserTestCard) -> ITestResultsControllerCardResultDto in
            return TestResultsControllerCardResultsDto(translations: dbUserTestCard.getTranslations().map({ (el) -> ITestResultsControllerTranslationDto in
                return TestResultsControllerTranslationDto(translation: el.translation, isRightAnswered: el.isRightAnswered)
            }), translatedWord: dbUserTestCard.translatedWord)
        }
        
        self.testResult = TestResultsControllerTestResult(cards: cardsResults, dictName: test.targetedDict?.name, score: Int(test.gradePercentage))
    }
}

protocol ITestResultsControllerDataSource: UITableViewDelegate, UITableViewDataSource, ITestResultsHeaderViewDelegate {
    func getDictName() -> String?
    
    func getPercentageScore() -> Int
}

protocol ITestResultsControllerState {
    var isSectionExpanded: [Bool] { get set }
}

class TestResultsControllerState: ITestResultsControllerState {
    var isSectionExpanded: [Bool]
    
    init(withDefaultSize: Int) {
        self.isSectionExpanded = Array.init(repeating: false, count: withDefaultSize)
    }
    
    init(isSectionExpanded: [Bool]) {
        self.isSectionExpanded = isSectionExpanded
    }
}

class TestResultsControllerDataSource: NSObject, ITestResultsControllerDataSource {
    
    private var dataProvider: ITestResultsControllerDataProvider
    
    private var state: ITestResultsControllerState
    
    var tableView: UITableView!
    
    var lastToggle: Int?
    
    private var headerViews: [TestResultsTableViewHeaderView?]
    
    func numberOfSections(in tableView: UITableView) -> Int {
        self.tableView = tableView
        return dataProvider.totalCards()
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let mycell = cell as! TestResultsTableViewCell
        if (lastToggle == indexPath.section) {
            mycell.baseShadowView.alpha = 0
            
            UIView.animate(withDuration: 0.3 * Double(indexPath.row + 1), animations: {
                mycell.baseShadowView.alpha = 1
            })
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = TestResultsTableViewHeaderView()
        view.delegate = self
        let card = self.dataProvider.getCardAt(pos: section)
        view.configure(config: TestResultsHeaderConfiguration(translatedWord: card.translatedWord, rightAnswered: self.dataProvider.rightAnsweredAt(pos: section), allTranslations: card.translations.count, section: section, isExpanded: self.state.isSectionExpanded[section], shouldAnimate: self.lastToggle == section))
        headerViews[section] = view
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (state.isSectionExpanded[section]) {
            return dataProvider.getCardAt(pos: section).translations.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        let row = indexPath.row
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TestResultsTableViewCell.cellId, for: indexPath) as? TestResultsTableViewCell else {
            fatalError()
        }
        var color = #colorLiteral(red: 0.9568627451, green: 0.7960784314, blue: 0.8039215686, alpha: 1)
        let trans = self.dataProvider.getTranslationAt(cardPos: section, transPos: row)
        if trans.isRightAnswered {
            color = #colorLiteral(red: 0.737254902, green: 0.9921568627, blue: 0.7960784314, alpha: 1)
        }
        
        cell.configure(config: TestResultsTableViewCellConfiguration(translation: trans.translation, backgroundColor: color))
        
        return cell
    }
    
    func didChangeExpandStateAt(section: Int) {
        lastToggle = section
        self.state.isSectionExpanded[section].toggle()
        self.tableView.reloadData()
    }
    
    func getDictName() -> String? {
        return self.dataProvider.getDictName()
    }
    
    func getPercentageScore() -> Int {
        return self.dataProvider.getPercentageScore()
    }
    
    init(dataProvider: ITestResultsControllerDataProvider, state: ITestResultsControllerState) {
        self.dataProvider = dataProvider
        self.headerViews = Array.init(repeating: nil, count: dataProvider.totalCards())
        self.state = state
    }
}
