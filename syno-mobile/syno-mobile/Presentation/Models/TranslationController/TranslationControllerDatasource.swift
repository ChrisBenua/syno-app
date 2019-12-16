//
//  TranslationControllerDatasource.swift
//  syno-mobile
//
//  Created by Ирина Улитина on 13.12.2019.
//  Copyright © 2019 Christian Benua. All rights reserved.
//

import Foundation
import UIKit


protocol ITranslationControllerDataProvider {
    var sourceCard: DbUserCard { get set }
    func getTranslations() -> [ITranslationCellConfiguration]
}

protocol ITranslationControllerDataSource: UITableViewDataSource, UITableViewDelegate {
    
    var viewModel: ITranslationControllerDataProvider { get }
}

class TranslationControllerDataProvider: ITranslationControllerDataProvider {
    func getTranslations() -> [ITranslationCellConfiguration] {
        let request = DbTranslation.requestTranslationsFrom(sourceCard: self._sourceCard)
        var res: [DbTranslation] = []
        do {
            res = try storageCoordinator.stack.mainContext.fetch(request)
        } catch let err {
            Logger.log("Error in fetching translations: \(#function)")
            Logger.log(err.localizedDescription)
        }
        
        return res.map { (trans) -> ITranslationCellConfiguration in
            trans.toTranslationCellConfig()
        }
    }
    
    private var _sourceCard: DbUserCard!
    
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

class TranslationControllerDataSource: NSObject, ITranslationControllerDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TranslationTableViewCell.cellId, for: indexPath) as? TranslationTableViewCell else {
            fatalError("Cant cast at \(#function)")
        }
        
        cell.setup(config: items[indexPath.row])
        return cell
    }
    
    var viewModel: ITranslationControllerDataProvider
    
    lazy var items: [ITranslationCellConfiguration] = {
        return viewModel.getTranslations()
    }()
    
    init(viewModel: ITranslationControllerDataProvider, sourceCard: DbUserCard) {
        self.viewModel = viewModel
        self.viewModel.sourceCard = sourceCard
    }
    
}

extension TranslationControllerDataSource {
}
