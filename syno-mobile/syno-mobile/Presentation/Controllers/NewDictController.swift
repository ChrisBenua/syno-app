import Foundation
import UIKit

/// Controller for creating new dictionary
class NewDictController: UIViewController {
    /// Service responsible for inner logic in `NewDictController`
    private var model: INewOrEditDictControllerModel
    
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
    
    /// Text Field for entering language of new dictionary
    lazy var languageTextField: UITextFieldWithLabel = {
        var tf = UITextFieldWithInsets(insets: UIEdgeInsets(top: 3, left: 7, bottom: 3, right: 7))
        tf.backgroundColor = .white
        tf.font = UIFont.systemFont(ofSize: 21)
        tf.clipsToBounds = true
        tf.placeholder = "Например, \"ru-en\""
        tf.layer.cornerRadius = 7
        tf.text = self.model.getDefaultLanguage()
        
        let label = UILabelWithInsets(padding: UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0))
        label.text = "Языки:"
        label.font = .systemFont(ofSize: 15, weight: .light)
        label.textColor = .gray
        let tfl = UITextFieldWithLabel(textField: tf, label: label, spacing: 3)
        return tfl
    }()
    
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
        
        self.stackView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 22, paddingLeft: 15, paddingBottom: 15, paddingRight: 15, width: 0, height: 0)
        
        
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.navigationItem.title = "Новый словарь"
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Добавить", style: .done, target: self, action: #selector(onSubmitButtonPressed))
        
        self.view.addSubview(baseShadowView)
        baseShadowView.anchor(top: self.view.topAnchor, left: self.view.leftAnchor, bottom: nil, right: self.view.rightAnchor, paddingTop: 100, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width: 0, height: 0)
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
