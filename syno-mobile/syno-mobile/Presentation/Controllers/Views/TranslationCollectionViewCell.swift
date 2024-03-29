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

class TranslationTableViewCellContentView: UIView {
  lazy var stackView: UIStackView = {
      let stackView = UIStackView(arrangedSubviews: [translationContainerView, transcriptionContainerView, commentContainerView, self.sampleContainer])
      stackView.axis = .vertical
      stackView.distribution = .fillEqually
      stackView.spacing = 12
      
      return stackView
  }()
  
  var padding: UIEdgeInsets
  var speakButtonPadding: UIEdgeInsets
  
  /// Base cell's view with shadow around it
  lazy var baseShadowView: BaseShadowView = {
      let view = BaseShadowView()
      view.layer.cornerRadius = 20
      view.cornerRadius = 20
      view.shadowView.shadowOffset = CGSize(width: 0, height: 4)
      view.containerViewBackgroundColor = UIColor(red: 240.0/255, green: 240.0/255, blue: 240.0/255, alpha: 1)
      
      view.containerView.addSubview(self.stackView)
      view.containerView.addSubview(self.speakButton)
      self.stackView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: padding.top, paddingLeft: padding.left, paddingBottom: padding.bottom, paddingRight: padding.right, width: 0, height: 0)
      
      self.speakButton.anchor(top: view.topAnchor, left: nil, bottom: nil, right: view.rightAnchor, paddingTop: speakButtonPadding.top, paddingLeft: speakButtonPadding.left, paddingBottom: speakButtonPadding.bottom, paddingRight: speakButtonPadding.right, width: 0, height: -0)
      self.speakButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
      self.speakButton.widthAnchor.constraint(equalTo: self.speakButton.heightAnchor, multiplier: 1.104).isActive = true
      
      return view
  }()
      
  init(padding: UIEdgeInsets = UIEdgeInsets(top: 22, left: 15, bottom: 15, right: 15), speakButtonPadding: UIEdgeInsets = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 13)) {
      self.padding = padding
      self.speakButtonPadding = speakButtonPadding
      super.init(frame: .zero)
      self.addSubview(baseShadowView)

      baseShadowView.anchor(top: self.topAnchor, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
  }
  
  /// Forbidden to create from Storyboard
  required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
  
  /// Text field for displaying and editing `translation`
  lazy var translationTextField: UITextField = {
      let tf = CommonUIElements.defaultTextField(backgroundColor: .white, edgeInsets: UIEdgeInsets(top: 3, left: 7, bottom: 3, right: 0))
      tf.layer.borderWidth = 0
      tf.placeholder = "Перевод"
      tf.font = UIFont.systemFont(ofSize: 18)
      
      return tf
  }()
  
  /// Text field for displaying and editing `comment`
  lazy var commentTextField: UITextField = {
      let tf = CommonUIElements.defaultTextField(backgroundColor: .white, edgeInsets: UIEdgeInsets(top: 3, left: 7, bottom: 3, right: 0))
      tf.placeholder = "Комментарий"
      tf.layer.borderWidth = 0
      tf.font = UIFont.systemFont(ofSize: 18)
  
      return tf
  }()
  
  ///Text field for displaying and editing `transcription`
  lazy var transcriptionTextField: UITextField = {
      let tf = CommonUIElements.defaultTextField(backgroundColor: .white, edgeInsets: UIEdgeInsets(top: 3, left: 7, bottom: 3, right: 0))
      tf.layer.borderWidth = 0
      tf.placeholder = "Транскрипция"
      tf.font = UIFont.systemFont(ofSize: 18)
      
      
      return tf
  }()
  
  /// Text field for displaying and editing `sample`
  lazy var sampleTextField: UITextField = {
      let tf = CommonUIElements.defaultTextField(backgroundColor: .white, edgeInsets: UIEdgeInsets(top: 3, left: 7, bottom: 3, right: 0))
      tf.layer.borderWidth = 0
      tf.placeholder = "Пример"

      return tf
  }()
  
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
  
  @objc func onSpeakButtonPressed() {
      AVSpeechSynthesizer().speak(AVSpeechUtterance(string: self.translationTextField.text ?? ""))
  }
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
  
    lazy var innerView: TranslationTableViewCellContentView = {
        let view = TranslationTableViewCellContentView()
        return view
    }()
    
    /// Updates `translationTextField`, `transcriptionTextField`, `commentTextField` and `sampleTextField`
    func updateUI() {
        self.innerView.translationTextField.text = translation
        self.innerView.transcriptionTextField.text = transcription
        self.innerView.commentTextField.text = comment
        self.innerView.sampleTextField.text = sample
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
    
    func setupEvents() {
        self.innerView.sampleTextField.delegate = self
        self.innerView.sampleTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        self.innerView.sampleTextField.addTarget(self, action: #selector(didEndEditingTextField(_:)), for: .editingDidEnd)
        self.innerView.sampleTextField.addTarget(self, action: #selector(editingDidBegin(_:)), for: .editingDidBegin)
      
      self.innerView.transcriptionTextField.delegate = self
      self.innerView.transcriptionTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
      self.innerView.transcriptionTextField.addTarget(self, action: #selector(didEndEditingTextField(_:)), for: .editingDidEnd)
      self.innerView.transcriptionTextField.addTarget(self, action: #selector(editingDidBegin(_:)), for: .editingDidBegin)
      
      self.innerView.commentTextField.delegate = self
      self.innerView.commentTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
      self.innerView.commentTextField.addTarget(self, action: #selector(didEndEditingTextField(_:)), for: .editingDidEnd)
      self.innerView.commentTextField.addTarget(self, action: #selector(editingDidBegin(_:)), for: .editingDidBegin)
      
      self.innerView.translationTextField.delegate = self
      self.innerView.translationTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
      self.innerView.translationTextField.addTarget(self, action: #selector(didEndEditingTextField(_:)), for: .editingDidEnd)
      self.innerView.translationTextField.addTarget(self, action: #selector(editingDidBegin(_:)), for: .editingDidBegin)
    }
        
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.backgroundColor = .clear
        self.contentView.addSubview(innerView)
        self.contentView.layer.cornerRadius = 20
        //self.layer.cornerRadius = 20
        self.contentView.clipsToBounds = true
      
        setupEvents()
        
        innerView.anchor(top: self.contentView.topAnchor, left: self.contentView.leftAnchor, bottom: self.contentView.bottomAnchor, right: self.contentView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    /// Forbidden to create from Storyboard
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0))
    }
    
    /// On begin editing in textField event listener
    @objc func editingDidBegin(_ textField: UITextField) {
        let bottomTextFieldPointYCoord = textField.frame.origin.y + textField.bounds.height
        
        let point = CGPoint(x: textField.frame.origin.x, y: bottomTextFieldPointYCoord)
        self.lastFocusedTextFieldBottomPoint = textField.convert(point, to: self.contentView)
        self.delegate?.setLastFocusedPoint(point: lastFocusedTextFieldBottomPoint!, sender: self)
    }
    
    /// On ended editing in textFields event listener
    @objc func didEndEditingTextField(_ textField: UITextField) {
        if textField == self.innerView.translationTextField && self.innerView.translationTextField.isUserInteractionEnabled {
            if (self.innerView.transcriptionTextField.text ?? "").count == 0 {
                let res = self.delegate?.getTranscription(for: textField.text ?? "")
                Logger.log("Transcription: \(res)")
                self.innerView.transcriptionTextField.text = res
                textFieldDidChange(self.innerView.transcriptionTextField)
            }
        }
        
        var ok = true
        for el in [innerView.sampleTextField, innerView.commentTextField, innerView.translationTextField, innerView.transcriptionTextField] {
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
        if ((textField.text?.count ?? 0) > 100) {
            textField.text = String(textField.text![..<textField.text!.index(textField.text!.startIndex, offsetBy: 100)])
        }
        delegate?.update(caller: self, newConf: generateCellConf())
    }
    
    /// Generates cell's configuration
    func generateCellConf() -> TranslationCellConfiguration {
        return TranslationCellConfiguration(translation: self.innerView.translationTextField.text, transcription: self.innerView.transcriptionTextField.text, comment: self.innerView.commentTextField.text, sample: self.innerView.sampleTextField.text)
    }
    
    /// `speakButton` click listener: speaks given word
    
}

extension TranslationTableViewCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        let arr = [self.innerView.translationTextField, self.innerView.transcriptionTextField, self.innerView.commentTextField, self.innerView.sampleTextField]
        let ind = arr.firstIndex(of: textField)!
        if (ind < arr.count - 1) {
            arr[ind + 1].becomeFirstResponder()
        }
        return true
    }
}
