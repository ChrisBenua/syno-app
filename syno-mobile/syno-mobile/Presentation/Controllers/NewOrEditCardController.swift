//
//  NewOrEditCardController.swift
//  syno-mobile
//
//  Created by Ирина Улитина on 08.04.2020.
//  Copyright © 2020 Christian Benua. All rights reserved.
//

import Foundation
import UIKit


class NewOrEditCardController: TranslationsCollectionViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Отмена", style: .done, target: self, action: #selector(cancelButtonClicked))
    }
    
    @objc func cancelButtonClicked() {
        self.dataSource.deleteTempCard {
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}
