import Foundation
import UIKit

/// Readonly modification of `TranslationTableViewCell`
class TranslationReadonlyTableViewCell: TranslationTableViewCell {
    override class func cellId() -> String {
        return "TranslationReadonlyTableViewCellId"
    }
    
    override func updateUI() {
        super.updateUI()
        super.innerView.commentTextField.isUserInteractionEnabled = false
        super.innerView.sampleTextField.isUserInteractionEnabled = false
        super.innerView.translationTextField.isUserInteractionEnabled = false
        super.innerView.transcriptionTextField.isUserInteractionEnabled = false
    }
}
