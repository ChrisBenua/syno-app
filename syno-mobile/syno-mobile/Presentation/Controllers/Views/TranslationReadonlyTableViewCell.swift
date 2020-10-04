import Foundation
import UIKit
import AVFoundation

class TranslationReadonlyTableViewCellContentView: UIView {
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
  lazy var translationTextField: UIScrollableTextField = {
      let tf = CommonUIElements.defaultTextField(backgroundColor: .white, edgeInsets: UIEdgeInsets(top: 3, left: 7, bottom: 3, right: 0))
      tf.isEnabled = false
      tf.layer.borderWidth = 0
      tf.placeholder = "Перевод"
      tf.font = UIFont.systemFont(ofSize: 18)
      
      let v = UIScrollableTextField(textField: tf)
      v.layer.cornerRadius = 10
      return v
  }()
  
  /// Text field for displaying and editing `comment`
  lazy var commentTextField: UIScrollableTextField = {
      let tf = CommonUIElements.defaultTextField(backgroundColor: .white, edgeInsets: UIEdgeInsets(top: 3, left: 7, bottom: 3, right: 0))
      tf.isEnabled = false
      tf.placeholder = "Комментарий"
      tf.layer.borderWidth = 0
      tf.font = UIFont.systemFont(ofSize: 18)
  
      let v = UIScrollableTextField(textField: tf)
      v.layer.cornerRadius = 10
      return v
  }()
  
  ///Text field for displaying and editing `transcription`
  lazy var transcriptionTextField: UIScrollableTextField = {
      let tf = CommonUIElements.defaultTextField(backgroundColor: .white, edgeInsets: UIEdgeInsets(top: 3, left: 7, bottom: 3, right: 0))
      tf.isEnabled = false
      tf.layer.borderWidth = 0
      tf.placeholder = "Транскрипция"
      tf.font = UIFont.systemFont(ofSize: 18)
      
      
      let v = UIScrollableTextField(textField: tf)
      v.layer.cornerRadius = 10
      return v
  }()
  
  /// Text field for displaying and editing `sample`
  lazy var sampleTextField: UIScrollableTextField = {
      let tf = CommonUIElements.defaultTextField(backgroundColor: .white, edgeInsets: UIEdgeInsets(top: 3, left: 7, bottom: 3, right: 0))
      tf.isEnabled = false
      tf.layer.borderWidth = 0
      tf.placeholder = "Пример"

      let v = UIScrollableTextField(textField: tf)
      v.layer.cornerRadius = 10
      v.clipsToBounds = true
      return v
  }()
  
  lazy var sampleContainer: UIView = {
      let label = UILabelWithInsets(padding: UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0))
      label.text = "Пример:"
      label.font = .systemFont(ofSize: 15, weight: .light)
      label.textColor = .gray
      
      let view = UIViewWithLabel(view: sampleTextField, label: label, spacing: 2)
      return view
  }()
  
  /// Wrapper view for label and  `commentTextField`
  lazy var commentContainerView: UIView = {
      let label = UILabelWithInsets(padding: UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0))
      label.text = "Комментарий:"
      label.font = .systemFont(ofSize: 15, weight: .light)
      label.textColor = .gray
      
      let view = UIViewWithLabel(view: commentTextField, label: label, spacing: 2)
      return view
  }()
  
  /// Wrapper view for label and `transcriptionTextField`
  lazy var transcriptionContainerView: UIView = {
      let label = UILabelWithInsets(padding: UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0))
      label.text = "Транскрипция:"
      label.font = .systemFont(ofSize: 15, weight: .light)
      label.textColor = .gray
      
      let view = UIViewWithLabel(view: transcriptionTextField, label: label, spacing: 2)
      return view
  }()
  
  /// Wrapper view for label and `translationTextField`
  lazy var translationContainerView: UIView = {
     let label = UILabelWithInsets(padding: UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0))
     label.text = "Перевод:"
     label.font = .systemFont(ofSize: 15, weight: .light)
     label.textColor = .gray
     
     let view = UIViewWithLabel(view: translationTextField, label: label, spacing: 2)
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

class TranslationReadonlyTableViewCell: UITableViewCell, IConfigurableTranslationCell, ITranslationCellConfiguration {
    /// gets cell reuseIdentifier
    public class func cellId() -> String {
        return "TranslationReadonlyTableViewCellId"
    }
    
    var translation: String?
    
    var transcription: String?
    
    var comment: String?
    
    var sample: String?
    
    /// Delegate for notifying on editing events
    weak var delegate: ITranslationCellDidChangeDelegate?
    
    /// Bottom left of last focused textField
    var lastFocusedTextFieldBottomPoint: CGPoint?
  
    lazy var innerView: TranslationReadonlyTableViewCellContentView = {
        let view = TranslationReadonlyTableViewCellContentView()
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
        
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.backgroundColor = .clear
        self.contentView.addSubview(innerView)
        self.contentView.layer.cornerRadius = 20
        //self.layer.cornerRadius = 20
        self.contentView.clipsToBounds = true
              
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
}

