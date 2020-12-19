import Foundation
import UIKit

/// Protocol for defining data for `TestControllerTranslationTableViewCell`
protocol ITestControllerTranslationCellConfiguration {
    /// User's answer
    var translation: String? { get set }
}

class TestControllerTranslationCellConfiguration: ITestControllerTranslationCellConfiguration {
    var translation: String?
    
    /**
     Creates new TestControllerTranslationCellConfiguration
     - Parameter translation: user's answer
     */
    init(translation: String?) {
        self.translation = translation
    }
}

/// Protocol for updating `TestControllerTranslationTableViewCell`
protocol IConfigurableTestControllerTranslationCell {
    /// updates `TestControllerTranslationTableViewCell` with given config
    func setup(config: ITestControllerTranslationCellConfiguration)
}

/// `TestControllerTranslationTableViewCell` on user answers change listener
protocol ITestControllerTranslationCellDelegate: class {
    /// User's answer change handler
    func textDidChange(sender: UITableViewCell, text: String?)
    
    func onReturn(sender: UITableViewCell)
}

class TestControllerTranslationTableViewCell: UITableViewCell, IConfigurableTestControllerTranslationCell {
    /// Cell's reuse identifier
    static let cellId = "TestControllerTranslationTableViewCellId"
    
    /// User's answer change listener
    weak var delegate: ITestControllerTranslationCellDelegate?
    
    /// TextField editing listener
    weak var editingDelegate: ITextFieldTestControllerEditingDelegate?
    
    /// Current user answer
    var translation: String?
    
    /// On textField begin editing event listener
    func textFieldDidBeginEditing(_ textField: UITextField) {
        editingDelegate?.beginEditingInCell(cell: self)
    }
    
    /// On textField end editing event listener
    func textFieldDidEndEditing(_ textField: UITextField) {
        editingDelegate?.endEditingInCell(cell: self)
    }
    
    /// Updates `translationTextField`
    func updateUI() {
        self.translationTextField.text = translation
    }
    
    func setup(config: ITestControllerTranslationCellConfiguration) {
        self.translation = config.translation
        
        updateUI()
    }
    
    /// TextField for displaying and editing answer
    lazy var translationTextField: UITextField = {
        let tf = UITextFieldWithInsets(insets: UIEdgeInsets(top: 2, left: 8, bottom: 2, right: 8))
        tf.backgroundColor = .white
        tf.font = .systemFont(ofSize: 22, weight: .light)
        tf.addTarget(self, action: #selector(onTranslationTextChanged(_:)), for: .allEditingEvents)
        tf.delegate = self
        tf.clipsToBounds = true
        
        tf.layer.cornerRadius = 7
        
        return tf
    }()
    
    /// TextField text change listener
    @objc func onTranslationTextChanged(_ textField: UITextField) {
        delegate?.textDidChange(sender: self, text: textField.text)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        self.backgroundColor = .clear
        
        self.contentView.addSubview(translationTextField)
        
        translationTextField.delegate = self
        
        translationTextField.anchor(top: self.contentView.topAnchor, left: self.contentView.leftAnchor, bottom: self.contentView.bottomAnchor, right: self.contentView.rightAnchor, paddingTop: 8, paddingLeft: 10, paddingBottom: 8, paddingRight: 10, width: 0, height: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TestControllerTranslationTableViewCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.delegate?.onReturn(sender: self)
        return true
    }
}
