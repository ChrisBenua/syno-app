//
//  TranslationReadonlyTableViewCell.swift
//  syno-mobile
//
//  Created by Ирина Улитина on 20.12.2019.
//  Copyright © 2019 Christian Benua. All rights reserved.
//

import Foundation
import UIKit

class TranslationReadonlyTableViewCell: TranslationTableViewCell {
    override class func cellId() -> String {
        return "TranslationReadonlyTableViewCellId"
    }
    
    override func updateUI() {
        super.updateUI()
        super.commentTextField.isUserInteractionEnabled = false
        super.sampleTextField.isUserInteractionEnabled = false
        super.translationTextField.isUserInteractionEnabled = false
        super.transcriptionTextField.isUserInteractionEnabled = false
    }
}
