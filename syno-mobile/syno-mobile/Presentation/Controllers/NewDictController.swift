import Foundation
import UIKit


extension Collection {
    func distance(to index: Index) -> Int { distance(from: startIndex, to: index) }
}

extension StringProtocol {
    func distance(of element: Element) -> Int? { firstIndex(of: element)?.distance(in: self) }
    func distance<S: StringProtocol>(of string: S) -> Int? { range(of: string)?.lowerBound.distance(in: self) }
}

extension String.Index {
    func distance<S: StringProtocol>(in string: S) -> Int { string.distance(to: self) }
}

/// Controller for creating new dictionary
class NewDictController: UIViewController {
    /// Service responsible for inner logic in `NewDictController`
    private var model: INewOrEditDictControllerModel
    private var didToggledOnceAfterDidEndEditing = false
    
    /// Text Field for entering name of new dictionary
    lazy var nameTextField: UITextFieldWithLabel = {
        var tf = UITextFieldWithInsets(insets: UIEdgeInsets(top: 3, left: 7, bottom: 3, right: 7))
        tf.backgroundColor = .white
        tf.font = UIFont.systemFont(ofSize: 21)
        tf.placeholder = "Например, \"Природа\""
        tf.clipsToBounds = true
        tf.layer.cornerRadius = 7
        tf.text = self.model.getDefaultName()
        
        let label = UILabelWithInsets(padding: UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0))
        label.text = "Название:"
        label.font = .systemFont(ofSize: 15, weight: .light)
        label.textColor = .gray
        let tfl = UITextFieldWithLabel(textField: tf, label: label, spacing: 3)
        return tfl
    }()
    
    lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .footnote)
        label.text = "Формат не соблюден"
        label.textColor = .red
        label.alpha = 0
        return label
    }()
  
    /// Text Field for entering language of new dictionary
    lazy var languageTextField: UITextFieldWithLabel = {
        var tf = UITextFieldWithInsets(insets: UIEdgeInsets(top: 3, left: 7, bottom: 3, right: 7))
        tf.backgroundColor = .white
        tf.font = UIFont.systemFont(ofSize: 21)
        tf.clipsToBounds = true
        tf.placeholder = "Формат: \"ru-en\""
        tf.autocapitalizationType = .none
        tf.layer.cornerRadius = 7
        tf.text = self.model.getDefaultLanguage()
        tf.addTarget(self, action: #selector(onLanguageTextFieldTextChanged), for: .editingChanged)
        tf.delegate = self
        
        let label = UILabelWithInsets(padding: UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0))
        label.text = "Языки:"
        label.font = .systemFont(ofSize: 15, weight: .light)
        label.textColor = .gray
        let tfl = UITextFieldWithLabel(textField: tf, label: label, spacing: 3)
        return tfl
    }()
  
    @objc func onLanguageTextFieldTextChanged() {
        let text = (self.languageTextField.getTextField()).text
        Logger.log("\(text)")
        if let index = text?.distance(of: "-") {
            if index > 0 && index < (text?.count ?? 0) - 1 {
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                self.errorLabel.alpha = 0
            } else {
                if didToggledOnceAfterDidEndEditing {
                    self.errorLabel.alpha = 1
                }
                self.navigationItem.rightBarButtonItem?.isEnabled = false
            }
        } else {
            if didToggledOnceAfterDidEndEditing {
                self.errorLabel.alpha = 1
            }
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
    
    /// Stack view with `nameTextField` and `languageTextField`
    lazy var stackView: UIView = {
        let sv = UIStackView(arrangedSubviews: [self.nameTextField, self.languageTextField])
        sv.axis = .vertical
        sv.spacing = 20
        sv.distribution = .fillEqually
        return sv
    }()
    
    /// Main view
    lazy var baseShadowView: BaseShadowView = {
        let view = BaseShadowView()
        view.cornerRadius = 20
        view.shadowView.shadowOffset = CGSize(width: 0, height: 4)
        view.containerViewBackgroundColor = UIColor(red: 240.0/255, green: 240.0/255, blue: 240.0/255, alpha: 1)
        
        view.addSubview(self.stackView)
        view.addSubview(self.errorLabel)
        
        self.stackView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: errorLabel.topAnchor, right: view.rightAnchor, paddingTop: 22, paddingLeft: 15, paddingBottom: 3, paddingRight: 15, width: 0, height: 0)
        self.errorLabel.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 10, paddingRight: 15, width: 0, height: 0)
        
        
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.navigationItem.title = self.model.getDefaultName() == nil ? "Новый словарь" : "Редактирование"
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: self.model.getDefaultName() == nil ? "Добавить" : "Сохранить", style: .done, target: self, action: #selector(onSubmitButtonPressed))
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        
        self.view.addSubview(baseShadowView)
        baseShadowView.anchor(top: self.view.topAnchor, left: self.view.leftAnchor, bottom: nil, right: self.view.rightAnchor, paddingTop: 100, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width: 0, height: 0)
        self.onLanguageTextFieldTextChanged()
    }
    
    /**
     Creates new `NewDictController`
     - Parameter model: Service responsible for inner logic of `NewDictController`
     */
    init(model: INewOrEditDictControllerModel) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Submit button click listener
    @objc func onSubmitButtonPressed() {
        model.saveNewDict(newDict: NewDictControllerNewDictDto(name: self.nameTextField.getTextField().text ?? "", language: self.languageTextField.getTextField().text ?? "")) {
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}

extension NewDictController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
  
  func textFieldDidEndEditing(_ textField: UITextField) {
    if let enabled = self.navigationItem.rightBarButtonItem?.isEnabled {
      self.errorLabel.alpha = enabled ? 0 : 1
      self.didToggledOnceAfterDidEndEditing = true
    } else {
      self.errorLabel.alpha = 0
    }
  }
}
