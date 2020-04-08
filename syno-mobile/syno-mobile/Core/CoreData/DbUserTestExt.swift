//
//  DbUserTest.swift
//  syno-mobile
//
//  Created by Ирина Улитина on 19.12.2019.
//  Copyright © 2019 Christian Benua. All rights reserved.
//

import Foundation
import CoreData

extension DbUserTest {
    
    func isEnded() -> Bool {
        return self.timePassed != nil
    }
    
    func endTest() {
        self.timePassed = Date()
        let allCnt = (self.targetedDict?.getCards() ?? []).map({ (card) -> Int in
            return card.getTranslations().count
        }).reduce(0) { (res, new) -> Int in
            return res + new
        }
        let passed = (self.testDict?.getCards() ?? []).flatMap({ (card) -> [DbUserTestTranslation] in
            return card.getTranslations()
        }).reduce(0, { (res, trans) -> Int32 in
            return res + (trans.isRightAnswered ? 1 : 0)
        })
        
        self.gradePercentage = Double(passed) * 100 / Double(allCnt)
    }
    
    static func insertUserTest(context: NSManagedObjectContext) -> DbUserTest? {
        guard let userTest = NSEntityDescription.insertNewObject(forEntityName: "DbUserTest", into: context) as? DbUserTest else {
            return nil
        }
        userTest.timeCreated = Date()

        return userTest
    }
    
    static func createUserTestFor(context: NSManagedObjectContext, dict: DbUserDictionary) -> DbUserTest {
        guard let userTest = insertUserTest(context: context) else {
            fatalError("Cant insert DbUserTest")
        }
        userTest.targetedDict = dict
        userTest.testDict = DbUserTestDict.fromDbUserDict(context: context, dict: dict, sourceTest: userTest)
        
        return userTest
    }
    
    static func requestLatestTests() -> NSFetchRequest<DbUserTest> {
        let request: NSFetchRequest<DbUserTest> = DbUserTest.fetchRequest()
        request.fetchLimit = 5
        request.sortDescriptors = [NSSortDescriptor(key: "timeCreated", ascending: false)]
        
        return request
    }
}
