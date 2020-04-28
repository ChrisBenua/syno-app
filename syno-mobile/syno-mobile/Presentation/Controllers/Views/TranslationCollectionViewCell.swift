import Foundation
import AVFoundation
import UIKit

/// Protocol for defining data for `TranslationTableViewCell`
protocol ITranslationCellConfiguration {
    /// One of word translations
    var translation: String? { get set }
    /// transcription of `translation`
    var transcription: String? { get set }
    /// user's comment
    var comment: String? { get set }
    /// User's usage sample
    var sample: String? { get set }
}

class TranslationCellConfiguration: ITranslationCellConfiguration {
    var translation: String?
    
    var transcription: String?
    
    var comment: String?
    
    var sample: String?
    
    /**
     Creates new `TranslationCellConfiguration`
     - Parameter translation: One of word translations
     - Parameter transcription: transcription of `translation`
     - Parameter comment: user's comment
     - Parameter sample: User's usage sample
     */
    init(translation: String?, transcription: String?, comment: String?, sample: String?) {
        self.translation = translation
        self.transcription = transcription
        self.comment = comment
        self.sample = sample
    }
}

/// Protocol for setting up data in `TranslationTableViewCell`
protocol IConfigurableTranslationCell {
    /// Passes needed data inside config instance
    func setup(config: ITranslationCellConfiguration)
}


class TranslationTableViewCell: UITableViewCell, IConfigurableTranslationCell, ITranslationCellConfiguration {
    /// gets cell reuseIdentifier
    public class func cellId() -> String {
        return "TranslationCellId"
    }
    
    var translation: String?
    
    var transcription: String?
    
    var comment: String?
    
    var sample: String?
    
    /// Delegate for notifying on editing events
    weak var delegate: ITranslationCellDidChangeDelegate?
    
    /// Bottom left of last focused textField
    var lastFocusedTextFieldBottomPoint: CGPoint?
    
    /// Updates `translationTextField`, `transcriptionTextField`, `commentTextField` and `sampleTextField`
    func updateUI() {
        self.translationTextField.text = translation
        self.transcriptionTextField.text = transcription
        self.commentTextField.text = comment
        self.sampleTextField.text = sample
    }
    
    /**
     Setups cell data
     - Parameter config: data wrapper
     */
    func setup(config: ITranslationCellConfiguration) {
        self.translation = config.translation
        self.comment = config.comment
        self.sample = config.sample
        self.transcription = config.transcription
        
        updateUI()
    }
    
    /// Stack view with all field inside
    lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [translationContainerView, transcriptionContainerView, commentContainerView, self.sampleContainer])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 12
        
        return stackView
    }()
    
    /// Base cell's view with shadow around it
    lazy var baseShadowView: UIView = {
        let view = BaseShadowView()
        view.cornerRadius = 20
        view.shadowView.shadowOffset = CGSize(width: 0, height: 4)
        view.containerViewBackgroundColor = UIColor(red: 240.0/255, green: 240.0/255, blue: 240.0/255, alpha: 1)
        
        view.addSubview(self.stackView)
        view.addSubview(self.speakButton)
        self.stackView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 22, paddingLeft: 15, paddingBottom: 15, paddingRight: 15, width: 0, height: 0)
        
        self.speakButton.anchor(top: view.topAnchor, left: nil, bottom: nil, right: view.rightAnchor, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 13, width: 0, height: -0)
        self.speakButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
        self.speakButton.widthAnchor.constraint(equalTo: self.speakButton.heightAnchor, multiplier: 1.104).isActive = true
        
        return view
    }()
        
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.backgroundColor = .clear
        self.contentView.addSubview(baseShadowView)
        
        baseShadowView.anchor(top: self.contentView.topAnchor, left: self.contentView.leftAnchor, bottom: self.contentView.bottomAnchor, right: self.contentView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    /// Forbidden to create from Storyboard
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Text field for displaying and editing `translation`
    lazy var translationTextField: UITextField = {
        let tf = CommonUIElements.defaultTextField(backgroundColor: .white, edgeInsets: UIEdgeInsets(top: 3, left: 15, bottom: 3, right: 0))
        tf.layer.borderWidth = 0
        tf.placeholder = "Перевод"
        tf.delegate = self
        tf.font = UIFont.systemFont(ofSize: 18)
        
        tf.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        tf.addTarget(self, action: #selector(didEndEditingTextField(_:)), for: .editingDidEnd)
        tf.addTarget(self, action: #selector(editingDidBegin(_:)), for: .editingDidBegin)
        
        return tf
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0))
    }
    
    /// Text field for displaying and editing `comment`
    lazy var commentTextField: UITextField = {
        let tf = CommonUIElements.defaultTextField(backgroundColor: .white, edgeInsets: UIEdgeInsets(top: 3, left: 15, bottom: 3, right: 0))
        tf.placeholder = "Комментарий"
        tf.layer.borderWidth = 0
        tf.font = UIFont.systemFont(ofSize: 18)
        tf.delegate = self

        tf.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        tf.addTarget(self, action: #selector(didEndEditingTextField(_:)), for: .editingDidEnd)
        tf.addTarget(self, action: #selector(editingDidBegin(_:)), for: .editingDidBegin)
        
        return tf
    }()
    
    ///Text field for displaying and editing `transcription`
    lazy var transcriptionTextField: UITextField = {
        let tf = CommonUIElements.defaultTextField(backgroundColor: .white, edgeInsets: UIEdgeInsets(top: 3, left: 15, bottom: 3, right: 0))
        tf.layer.borderWidth = 0
        tf.placeholder = "Транскрипция"
        tf.font = UIFont.systemFont(ofSize: 18)
        tf.delegate = self

        tf.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        tf.addTarget(self, action: #selector(didEndEditingTextField(_:)), for: .editingDidEnd)
        tf.addTarget(self, action: #selector(editingDidBegin(_:)), for: .editingDidBegin)
        
        return tf
    }()
    
    /// Text field for displaying and editing `sample`
    lazy var sampleTextField: UITextField = {
        let tf = CommonUIElements.defaultTextField(backgroundColor: .white, edgeInsets: UIEdgeInsets(top: 3, left: 15, bottom: 3, right: 0))
        tf.layer.borderWidth = 0
        tf.delegate = self
        tf.placeholder = "Пример"
        tf.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        tf.addTarget(self, action: #selector(didEndEditingTextField(_:)), for: .editingDidEnd)
        tf.addTarget(self, action: #selector(editingDidBegin(_:)), for: .editingDidBegin)
        
        return tf
    }()
    
    /// On begin editing in textField event listener
    @objc func editingDidBegin(_ textField: UITextField) {
        let bottomTextFieldPointYCoord = textField.frame.origin.y + textField.bounds.height
        
        let point = CGPoint(x: textField.frame.origin.x, y: bottomTextFieldPointYCoord)
        self.lastFocusedTextFieldBottomPoint = textField.convert(point, to: self.contentView)
        self.delegate?.setLastFocusedPoint(point: lastFocusedTextFieldBottomPoint!, sender: self)
    }
    
    /// On ended editing in textFields event listener
    @objc func didEndEditingTextField(_ textField: UITextField) {
        
        if textField == self.translationTextField && self.translationTextField.isUserInteractionEnabled {
            if (self.transcriptionTextField.text ?? "").count == 0 {
                let res = self.delegate?.getTranscription(for: textField.text ?? "")
                Logger.log("Transcription: \(res)")
                self.transcriptionTextField.text = res
                textFieldDidChange(self.transcriptionTextField)
            }
        }
        
        var ok = true
        for el in [sampleTextField, commentTextField, translationTextField, transcriptionTextField] {
            if el.isEditing {
                ok = false
            }
        }
        
        if ok {
            self.delegate?.didEndEditing()
        }
    }
    
    /// On text changed in textField event listener
    @objc private func textFieldDidChange(_ textField: UITextField) {
        delegate?.update(caller: self, newConf: generateCellConf())
    }
    
    /// Generates cell's configuration
    func generateCellConf() -> TranslationCellConfiguration {
        return TranslationCellConfiguration(translation: self.translationTextField.text, transcription: self.transcriptionTextField.text, comment: self.commentTextField.text, sample: self.sampleTextField.text)
    }
    
    /// Wrapper view for label and `sampleTextField`
    lazy var sampleContainer: UIView = {
        let label = UILabelWithInsets(padding: UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0))
        label.text = "Пример:"
        label.font = .systemFont(ofSize: 15, weight: .light)
        label.textColor = .gray
        
        let view = UITextFieldWithLabel(textField: sampleTextField, label: label, spacing: 2)
        return view
    }()
    
    /// Wrapper view for label and  `commentTextField`
    lazy var commentContainerView: UIView = {
        let label = UILabelWithInsets(padding: UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0))
        label.text = "Комментарий:"
        label.font = .systemFont(ofSize: 15, weight: .light)
        label.textColor = .gray
        
        let view = UITextFieldWithLabel(textField: commentTextField, label: label, spacing: 2)
        return view
    }()
    
    /// Wrapper view for label and `transcriptionTextField`
    lazy var transcriptionContainerView: UIView = {
        let label = UILabelWithInsets(padding: UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0))
        label.text = "Транскрипция:"
        label.font = .systemFont(ofSize: 15, weight: .light)
        label.textColor = .gray
        
        let view = UITextFieldWithLabel(textField: transcriptionTextField, label: label, spacing: 2)
        return view
    }()
    
    /// Wrapper view for label and `translationTextField`
    lazy var translationContainerView: UIView = {
       let label = UILabelWithInsets(padding: UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0))
       label.text = "Перевод:"
       label.font = .systemFont(ofSize: 15, weight: .light)
       label.textColor = .gray
       
       let view = UITextFieldWithLabel(textField: translationTextField, label: label, spacing: 2)
       return view
    }()
    
    /// Button with sound icon
    lazy var speakButton: UIButton = {
        let button = UIButton(type: UIButton.ButtonType.system)
        
        button.setImage(#imageLiteral(resourceName: "Component 5"), for: .normal)
        
        button.addTarget(self, action: #selector(onSpeakButtonPressed), for: .touchUpInside)
        
        return button
    }()
    
    /// `speakButton` click listener: speaks given word
    @objc func onSpeakButtonPressed() {
        AVSpeechSynthesizer().speak(AVSpeechUtterance(string: self.translationTextField.text ?? ""))
    }
}

extension TranslationTableViewCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        let arr = [self.translationTextField, self.transcriptionTextField, self.commentTextField, self.sampleTextField]
        let ind = arr.firstIndex(of: textField)!
        if (ind < arr.count - 1) {
            arr[ind + 1].becomeFirstResponder()
        }
        return true
    }
}
