import Foundation
import UIKit

/// Defines actions with view to move view up and down depending on keyboard position
protocol IScrollableToPoint: class {
    /// Gives info about last focused view's position on screen
    func scrollToPoint(point: CGPoint, sender: UIView?)
    
    /// Notifies when all input view are not focused
    func scrollToTop()
}

/// Defines protocol for interacting with `TestView`
protocol ITestView: UIView, ITestViewControllerDataSourceReactor, IScrollableToPoint {
    var tableView: UITableView { get }
    var parentController: IScrollableToPoint? { get set }
    func makeFirstTextFieldResponder()
    
    var model: ITestViewControllerModel { get }
}

/// View for TestController with only 1 card
class TestView: UIView, ITestView {
    func makeFirstTextFieldResponder() {
        if let cell = self.tableView.cellForRow(at: IndexPath(item: 0, section: 0)) as? TestControllerTranslationTableViewCell {
            cell.translationTextField.becomeFirstResponder()
        }
    }
    
    func scrollToTop() {
        parentController?.scrollToTop()
    }
    
    func scrollToPoint(point: CGPoint, sender: UIView?) {
        parentController?.scrollToPoint(point: point, sender: sender)
    }
    
    weak var parentController: IScrollableToPoint?
    var model: ITestViewControllerModel
    var addButton: UIButton!
    
    /// Updates card number, translated word and index translation number
    func setHeaderData() {
        self.cardNumberLabel.text = "\(model.dataSource.state.itemNumber + 1)/\(model.dataSource.dataProvider.count)"
        self.translatedWordView.translatedWordLabel.text = model.dataSource.dataProvider.getItem(cardPos: model.dataSource.state.itemNumber).translatedWord
        let translationsAmount = model.dataSource.dataProvider.getItem(cardPos: model.dataSource.state.itemNumber).translationsCount
        self.translationsNumberLabel.text = "\(translationsAmount) \(NumbersEndingHelper.translations(translationsAmount: translationsAmount))"
    }
    
    /// Label for displaying index number of current card
    lazy var cardNumberLabel: UILabel = {
        let cardNumberLabel = UILabel(); cardNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        cardNumberLabel.font = UIFont.systemFont(ofSize: 20)
        cardNumberLabel.textAlignment = .center
        
        return cardNumberLabel
    }()
    
    /// View for displaying current translated word
    lazy var translatedWordView: TranslatedWordView = {
        let wordView = TranslatedWordView()
        wordView.setContentCompressionResistancePriority(UILayoutPriority(1000), for: .horizontal)
        wordView.translatedWordLabel.setContentCompressionResistancePriority(UILayoutPriority(1000), for: .horizontal)
        wordView.translatedWordLabel.isUserInteractionEnabled = false
        
        return wordView
    }()
    
    /// View for displaying amount of translations in current card
    lazy var translationsNumberLabel: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        
        return label
    }()
    
    /// Wrapper-view for `translationsNumberLabel`, `translatedWordView` and `cardNumberLabel`
    lazy var headerView: UIView = {
        let view = UIView()
        
        let sepView1 = UIView(); sepView1.translatesAutoresizingMaskIntoConstraints = false
        
        let sv = UIStackView(arrangedSubviews: [cardNumberLabel, translatedWordView, sepView1, translationsNumberLabel])
        sv.axis = .vertical
        sv.distribution = .fill
        sv.setCustomSpacing(10, after: cardNumberLabel)
        
        sepView1.heightAnchor.constraint(equalTo: sv.heightAnchor, multiplier: 0.15).isActive = true
        
        view.addSubview(sv)
        sv.anchor(top: view.topAnchor, left: nil, bottom: view.bottomAnchor, right: nil, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        sv.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        sv.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1).isActive = true
        sv.setContentCompressionResistancePriority(UILayoutPriority(1000), for: .horizontal)
        
        return view
    }()
    
    /// Wrapper view for actions buttons
    lazy var controlsView: UIView = {
        addButton = UIButton()
        addButton.setImage(#imageLiteral(resourceName: "Component 4"), for: .normal)
        
        addButton.addTarget(self, action: #selector(onAddAnswerButton), for: .touchUpInside)
        
        let view = UIView()
        view.addSubview(addButton)

        addButton.anchor(top: view.topAnchor, left: nil, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 10, paddingLeft: 0, paddingBottom: 10, paddingRight: 20, width: 0, height: 0)
        addButton.widthAnchor.constraint(equalToConstant: 27).isActive = true
        addButton.heightAnchor.constraint(equalToConstant: 27).isActive = true
        
        return view
    }()
    
    /// Add answer button click listener
    @objc func onAddAnswerButton() {
        if (self.model.dataSource.dataProvider.getItem(cardPos: self.model.dataSource.state.itemNumber).translationsCount > tableView.numberOfRows(inSection: 0)) {
            self.addButton.flash(toValue: 0.6, duration: 0.2)
            self.model.dataSource.onAddLineForAnswer()
        }
    }
    
    /// Table view with user's answers
    lazy var tableView: UITableView = {
        let tv = PlainTableView()
        tv.dataSource = self.model.dataSource
        tv.delegate = self.model.dataSource
        
        tv.backgroundColor = .clear
        tv.separatorColor = .clear
        
        tv.separatorInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        tv.separatorInsetReference = .fromCellEdges
        
        tv.register(TestControllerTranslationTableViewCell.self, forCellReuseIdentifier: TestControllerTranslationTableViewCell.cellId)
        
        return tv
    }()
    
    /// Wrapper-view for `controlsView` and `tableView`
    lazy var collectionContainerView: UIView = {
        let view = BaseShadowView()
        view.shadowView.shadowOffset = CGSize(width: 0, height: 4)

        view.containerViewBackgroundColor = UIColor(red: 240.0/255, green: 240.0/255, blue: 240.0/255, alpha: 1)
        view.cornerRadius = 20
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        
        //view.addSubview(self.controlsView)
        view.addSubview(self.tableView)
        
//        self.controlsView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 5, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        self.tableView.anchor(top: view.topAnchor, left: nil, bottom: view.bottomAnchor, right: nil, paddingTop: 13, paddingLeft: 0, paddingBottom: 13, paddingRight: 0, width: 0, height: 0)
        self.tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        self.tableView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -22).isActive = true
        
        return view
    }()
    
    /// Wrapper-view for all views on screen
    lazy var contentView: UIView = {
        let view = UIView()
        view.addSubview(self.headerView)
        view.addSubview(self.collectionContainerView)
        
        self.headerView.anchor(top: view.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        self.headerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        self.headerView.widthAnchor.constraint(greaterThanOrEqualTo: view.widthAnchor, constant: -40).isActive = true
        self.headerView.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, constant: 0).isActive = true
        
        self.collectionContainerView.anchor(top: self.headerView.bottomAnchor, left: nil, bottom: view.bottomAnchor, right: nil, paddingTop: 10, paddingLeft: 0, paddingBottom: 20, paddingRight: 0, width: 0, height: 0)
        self.collectionContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        self.collectionContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: 0).isActive = true
        
        return view
    }()
    
    /**
     Creates new `TestView`
     - Parameter model: instance for handling inner logic of `TestView`
     */
    init(model: ITestViewControllerModel) {
        self.model = model
        super.init(frame: .zero)
        self.model.dataSource.reactor = self
        self.model.dataSource.onFocusedLabelDelegate = self

        
        self.addSubview(self.contentView)
        self.contentView.anchor(top: self.topAnchor, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        setHeaderData()
    }
    
    /// Forbidden to create view from Storyboard
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addItems(indexPaths: [IndexPath]) {
        self.tableView.insertRows(at: indexPaths, with: .automatic)
    }
    
    func deleteItems(indexPaths: [IndexPath]) {
        self.tableView.deleteRows(at: indexPaths, with: .automatic)
    }
}

class TestViewGenerator {
    /// Generates new `TestView` with given instance for handling inner logic
    func generate(model: ITestViewControllerModel) -> ITestView {
        return TestView(model: model)
    }
}
