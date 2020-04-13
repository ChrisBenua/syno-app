//
//  TestAndLearnControllerDatasource.swift
//  syno-mobile
//
//  Created by Ирина Улитина on 19.12.2019.
//  Copyright © 2019 Christian Benua. All rights reserved.
//

import Foundation
import UIKit
import CoreData

enum TestAndLearnModes {
    case learnMode
    case testMode
}

protocol ITestAndLearnStateReactor: class {
    func onStateChanged(newState: TestAndLearnModes)
}

protocol ITestAndLearnReactor: class {
    func showLearnController(controller: UIViewController)
    
    func onChangeControllerTitle(newMode: TestAndLearnModes)
}

protocol ITestAndLearnDictionaryControllerState {
    var testAndLearnMode: TestAndLearnModes { get set }
}

class TestAndLearnDictionaryControllerState: ITestAndLearnDictionaryControllerState {
    var testAndLearnMode: TestAndLearnModes
    
    init() {
        testAndLearnMode = .learnMode
    }
}

protocol ITestAndLearnDictionaryDataSource: ICommonDictionaryControllerDataSource, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, ITestAndLearnHeaderDelegate {
    var state: ITestAndLearnDictionaryControllerState { get }
    var delegate: ITestAndLearnReactor? { get set }
}

class TestAndLearnDictionaryDataSource: NSObject, ITestAndLearnDictionaryDataSource {
    
    weak var delegate: ITestAndLearnReactor?
    
    var state: ITestAndLearnDictionaryControllerState
    
    func onSegmentChanged() {
        if state.testAndLearnMode == .learnMode {
            state.testAndLearnMode = .testMode
        } else {
            state.testAndLearnMode = .learnMode
        }
        delegate?.onChangeControllerTitle(newMode: state.testAndLearnMode)
        print("segment changed")
    }
    
    var fetchedResultsController: NSFetchedResultsController<DbUserDictionary>
    
    var viewModel: IDictionaryControllerDataProvider
    
    private var presAssembly: IPresentationAssembly
    
    var header: TestAndLearnControllerHeader?
    
    init(viewModel: IDictionaryControllerDataProvider, presAssembly: IPresentationAssembly) {
        self.viewModel = viewModel
        self.presAssembly = presAssembly
        self.state = TestAndLearnDictionaryControllerState()
        fetchedResultsController = self.viewModel.generateDictControllerFRC()
    }
        
    func performFetch() {
        do {
            try fetchedResultsController.performFetch()
        } catch let err {
            Logger.log("Cant perform fetch")
            Logger.log(err.localizedDescription)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TestAndLearnControllerHeader.headerId, for: indexPath) as! TestAndLearnControllerHeader
        header.delegate = self
        switch self.state.testAndLearnMode {
        case .learnMode:
            header.segmentControl.selectedSegmentIndex = 0
        case .testMode:
            header.segmentControl.selectedSegmentIndex = 1
        }
        
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let sections = self.fetchedResultsController.sections else {
            fatalError("No sections in FRC")
        }
        return sections[section].numberOfObjects
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TestAndLearnCollectionViewCell.cellId, for: indexPath) as? TestAndLearnCollectionViewCell else {
            fatalError()
        }
        
        cell.setup(config: self.fetchedResultsController.object(at: indexPath).toTestAndLearnCellConfiguration())
        return cell
    }
}

extension TestAndLearnDictionaryDataSource {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (self.state.testAndLearnMode == .learnMode) {
            let controller = self.presAssembly.learnController(sourceDict: self.fetchedResultsController.object(at: indexPath))
            self.delegate?.showLearnController(controller: controller)
        } else {
            let contoller = self.presAssembly.testController(sourceDict: self.fetchedResultsController.object(at: indexPath))
            self.delegate?.showLearnController(controller: contoller)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width / 2-20, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
        
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 15
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 50)
    }
}
