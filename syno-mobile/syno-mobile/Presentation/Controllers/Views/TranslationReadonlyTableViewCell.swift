import Foundation
import UIKit

/// Readonly modification of `TranslationTableViewCell`
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
