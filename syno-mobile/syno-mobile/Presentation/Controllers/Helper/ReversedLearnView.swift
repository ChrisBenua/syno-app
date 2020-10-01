import Foundation
import UIKit


class ReversedLearnView: UIView {
  struct State {
    let cardNumber: Int
    var state: State = .noanswer
    
    enum State {
      case noanswer, answer
    }
  }
  private var state: State
  private var model: IReversedLearnControllerModel
  
  lazy var compactTranslationViews: [UILabel] = {
    let translations = model.getCard(at: state.cardNumber).translations
    return translations.map { (translation) -> UILabel in
      let label = UILabelWithInsets(padding: .init(top: 5, left: 10, bottom: 5, right: 10))
      label.backgroundColor = UIColor.init(red: 250.0/255, green: 250.0/255, blue: 250.0/255, alpha: 1)
      label.layer.cornerRadius = 10
      label.clipsToBounds = true
      label.layer.shadowColor = UIColor.init(white: 0.6, alpha: 1).cgColor
      label.layer.shadowRadius = 6
      label.layer.shadowOffset = CGSize(width: 0, height: 0)
      label.textAlignment = .center
      label.setContentHuggingPriority(.defaultLow, for: .horizontal)
      label.setContentHuggingPriority(.defaultLow, for: .vertical)

      label.font = .systemFont(ofSize: 18)
      label.text = translation.translation
      return label
    }
  }()
  
  lazy var translationCardViews: [TranslationTableViewCellContentView] = {
    let translations = model.getCard(at: state.cardNumber).translations
    return translations.map { (translation) -> TranslationTableViewCellContentView in
      let cell = TranslationTableViewCellContentView(padding: UIEdgeInsets(top: 27, left: 20, bottom: 15, right: 20), speakButtonPadding: UIEdgeInsets(top: 12.5, left: 0, bottom: 0, right: 15))
      cell.translationTextField.isUserInteractionEnabled = false
      cell.translationTextField.text = translation.translation
      
      cell.transcriptionTextField.isUserInteractionEnabled = false
      cell.transcriptionTextField.text = translation.transcription
      
      cell.commentTextField.isUserInteractionEnabled = false
      cell.commentTextField.text = translation.comment
      
      cell.sampleTextField.isUserInteractionEnabled = false
      cell.sampleTextField.text = translation.sample
      
      return cell
    }
  }()
  
  lazy var headerLabel: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: 20)
    label.text = "\(self.state.cardNumber + 1)/\(self.model.getCardsCount())"
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  lazy var compactTranslationsContainerView: BaseShadowView = {
    let view = BaseShadowView()
    view.layer.cornerRadius = 20
    view.cornerRadius = 20
    view.shadowView.shadowOffset = CGSize(width: 0, height: 4)
    view.containerViewBackgroundColor = UIColor(red: 240.0/255, green: 240.0/255, blue: 240.0/255, alpha: 1)
    
    return view
  }()
  
  lazy var answerView: TranslatedWordView = {
    let view = TranslatedWordView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.translatedWordLabel.text = self.model.getCard(at: self.state.cardNumber).translatedWord
    view.alpha = 0
    
    return view
  }()
  
  lazy var showAnswerButton: UIButton = {
    let button = CommonUIElements.defaultSubmitButton(text: "Показать перевод", backgroundColor: UIColor.init(red: 81.0/255, green: 111.0/255, blue: 138.0/255, alpha: 1), textColor: .white)
    button.layer.masksToBounds = false
    button.addTarget(self, action: #selector(onShowAnswerButtonClicked), for: .touchUpInside)
    button.layer.shadowColor = UIColor.init(white: 0.6, alpha: 1).cgColor
    button.layer.shadowRadius = 6
    button.layer.shadowOffset = CGSize(width: 0, height: 0)
    button.layer.shadowOpacity = 0
    button.addTarget(self, action: #selector(onButtonTouchBegan), for: .touchDown)
    button.addTarget(self, action: #selector(onButtonTouchEnd), for: .touchUpOutside)
    return button
  }()
  
  @objc func onButtonTouchBegan() {
    Logger.log(#function)
    animateIn()
  }
  
  func animateOut() {
    UIView.animate(withDuration: 0.3) {
      self.showAnswerButton.transform = .identity
    }
  }
  
  func animateIn() {
    UIView.animate(withDuration: 0.3, animations: {
      self.showAnswerButton.transform = .init(scaleX: 0.97, y: 0.97)
    }) { (success) in
      Logger.log("\(success)")
    }
  }
  
  @objc func onButtonTouchEnd() {
    Logger.log(#function)
    animateOut()
  }
  
  @objc func onShowAnswerButtonClicked() {
    animateOut()
    self.showAnswerButton.flash(toValue: 0.5, duration: 0.25)
    if state.state == .noanswer {
      self.state.state = .answer
      
      UIView.transition(with: self.showAnswerButton, duration: 0.8, options: .transitionCrossDissolve, animations: {
        self.showAnswerButton.setTitle("Показать Карточки", for: .normal)
      })
      
      Logger.log("onShowAnswerButtonClicked")
    
      self.cardsHolderViewHeightAnchor?.isActive = false

      UIView.animate(withDuration: 0.5) {
        self.answerView.alpha = 1
        self.cardsHolderView.alpha = 1
      }
    }
  }
  
  lazy var translationsStackView: UIStackView = {
    let translationsStackView = UIStackView(arrangedSubviews: self.compactTranslationViews)
    translationsStackView.axis = .vertical
    translationsStackView.spacing = 10
    return translationsStackView
  }()
  
  lazy var stackView: UIStackView = {
    let sv = UIStackView(arrangedSubviews: [self.translationsStackView])
    sv.axis = .vertical
    sv.spacing = 10
    return sv
  }()
  
  lazy var cardsHolderView: UIView = {
    let sv = UIStackView(arrangedSubviews: self.translationCardViews)
    sv.axis = .vertical
    sv.spacing = 10
    self.cardsHolderViewHeightAnchor = sv.heightAnchor.constraint(equalToConstant: 0)
    self.cardsHolderViewHeightAnchor.isActive = true
    sv.alpha = 0
    return sv
  }()
  
  var cardsHolderViewHeightAnchor: NSLayoutConstraint!
  
  private func layout() {
    self.compactTranslationsContainerView.addSubview(stackView)
    stackView.anchor(top: compactTranslationsContainerView.topAnchor, left: compactTranslationsContainerView.leftAnchor, bottom: compactTranslationsContainerView.bottomAnchor, right: compactTranslationsContainerView.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 20, paddingRight: 20, width: 0, height: 0)
    
    self.addSubview(headerLabel)
    self.addSubview(compactTranslationsContainerView)
    
    self.headerLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 20).isActive = true
    self.headerLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
    self.compactTranslationsContainerView.anchor(top: headerLabel.bottomAnchor, left: self.leftAnchor, bottom: nil, right: self.rightAnchor, paddingTop: 10, paddingLeft: 13.5, paddingBottom: 0, paddingRight: 13.5, width: 0, height: 0)
    
    
    self.addSubview(showAnswerButton)
    self.addSubview(answerView)
    self.addSubview(cardsHolderView)
    
    showAnswerButton.anchor(top: compactTranslationsContainerView.bottomAnchor, left: compactTranslationsContainerView.leftAnchor, bottom: nil, right: compactTranslationsContainerView.rightAnchor, paddingTop: 40, paddingLeft: 19, paddingBottom: 0, paddingRight: 19, width: 0, height: 40)
    answerView.anchor(top: showAnswerButton.bottomAnchor, left: compactTranslationsContainerView.leftAnchor, bottom: nil, right: compactTranslationsContainerView.rightAnchor, paddingTop: 20, paddingLeft: 15, paddingBottom: 0, paddingRight: 15, width: 0, height: 0)
    cardsHolderView.anchor(top: answerView.bottomAnchor, left: compactTranslationsContainerView.leftAnchor, bottom: self.bottomAnchor, right: compactTranslationsContainerView.rightAnchor, paddingTop: 20, paddingLeft: 0, paddingBottom: 10, paddingRight: 0, width: 0, height: 0)
  }
  
  init(state: State, model: IReversedLearnControllerModel) {
    self.state = state
    self.model = model
    super.init(frame: .zero)
    self.layout()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

class ReversedLearnViewGenerator {
    /// Generates new `TestView` with given instance for handling inner logic
  func generate(model: IReversedLearnControllerModel, state: ReversedLearnView.State) -> ReversedLearnView {
    return ReversedLearnView(state: state, model: model)
  }
}
