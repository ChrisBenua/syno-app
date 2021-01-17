import Foundation
import UIKit

/// Defines needed actions with LearnView
protocol ILearnView: UIView, ILearnControllerDataSourceReactor {
    var controlsView: UIView { get }
    
    func editAssociatedCard()
    
    func refreshData()
}

class LearnView: UIView, ILearnView {
    var dataSource: ILearnControllerTableViewDataSource
    weak var actionsDelegate: ILearnControllerActionsDelegate?
    weak var scrollViewDelegate: UIScrollViewDelegate?
    var plusOneButton: UIButton!
    var showAllButton: UIButton!
    
    /// Updates card number, number of translations and translated word
    func setHeaderData() {
        cardNumberLabel.text = "\(self.dataSource.state.itemNumber + 1)/\(self.dataSource.viewModel.count)"
        let translationsAmount = self.dataSource.viewModel.getItems(currCardPos: self.dataSource.state.itemNumber).count
        translationsNumberLabel.text = "\(translationsAmount) \(NumbersEndingHelper.translations(translationsAmount: translationsAmount))"
        translatedWordView.translatedWordLabel.text = self.dataSource.viewModel.getTranslatedWord(cardPos: self.dataSource.state.itemNumber)
    }
    
    func editAssociatedCard() {
        self.dataSource.showEditCardController()
    }
    
    func refreshData() {
        self.dataSource.refreshData()
    }
    
    /// TableView with translations
    lazy var tableView: UITableView = {
        let tableView = PlainTableView()
        tableView.delegate = self.dataSource
        tableView.dataSource = self.dataSource
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        
        tableView.register(TranslationReadonlyTableViewCell.self, forCellReuseIdentifier: TranslationReadonlyTableViewCell.cellId())
        
        return tableView
    }()
    
    /// Wrapper view for `tableView` and `controlsView`
    lazy var collectionContainerView: BaseShadowView = {
        let view = BaseShadowView()
        view.shadowView.shadowOffset = CGSize(width: 0, height: 4)

        view.containerViewBackgroundColor = UIColor(red: 247.0/255, green: 247.0/255, blue: 247.0/255, alpha: 1)
        view.cornerRadius = 20
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let tableViewWrapper = UIView()
        tableViewWrapper.addSubview(tableView)
        tableView.anchor(top: tableViewWrapper.topAnchor, left: tableViewWrapper.leftAnchor, bottom: tableViewWrapper.bottomAnchor, right: tableViewWrapper.rightAnchor, padding: .init(top: 0, left: 12.5, bottom: 10, right: 12.5))
        let sv = UIStackView(arrangedSubviews: [self.controlsView, tableViewWrapper])
        sv.axis = .vertical

        view.containerView.addSubview(sv)
        sv.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, padding: .init(top: 5, left: 0, bottom: 0, right: 0))
//
//        view.addSubview(controlsView)
//        view.addSubview(tableView)
//        self.controlsView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 5, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
//
//        self.tableView.anchor(top: self.controlsView.bottomAnchor, left: nil, bottom: view.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 10, paddingRight: 15, width: 0, height: 0)
//        self.tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
//        self.tableView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -25).isActive = true
//
        return view
    }()
    
    /// View for displaying current translated word
    lazy var translatedWordView: TranslatedWordView = {
        let translatedWordView = TranslatedWordView()
        translatedWordView.translatedWordLabel.setContentCompressionResistancePriority(UILayoutPriority(1000), for: .horizontal)
        translatedWordView.setContentCompressionResistancePriority(UILayoutPriority(1000), for: .horizontal)
        translatedWordView.translatedWordLabel.isUserInteractionEnabled = false
        
        return translatedWordView
    }()
    
    /// Wrapper view with `cardNumberLabel`, `translatedWordView`, `translationsNumberLabel`
    lazy var headerView: UIView = {
        let view = UIView()
        
        let cardNumberLabel = self.cardNumberLabel
        
        let translationsNumberLabel = self.translationsNumberLabel
        
        let sepView1 = UIView(); sepView1.translatesAutoresizingMaskIntoConstraints = false
        
        let sv = UIStackView(arrangedSubviews: [cardNumberLabel, translatedWordView, sepView1, translationsNumberLabel])
        sv.axis = .vertical
        sv.distribution = .fill
        sv.setCustomSpacing(10, after: cardNumberLabel)
        
        //sepView.heightAnchor.constraint(equalTo: sv.heightAnchor, multiplier: 0.2).isActive = true
        sepView1.heightAnchor.constraint(equalTo: sv.heightAnchor, multiplier: 0.15).isActive = true
        
        view.addSubview(sv)
        sv.anchor(top: view.topAnchor, left: nil, bottom: view.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        sv.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        sv.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1).isActive = true
        sv.setContentCompressionResistancePriority(UILayoutPriority(1000), for: .horizontal)
        return view
    }()
    
    /// View with action buttons
    lazy var controlsView: UIView = {
        plusOneButton = CommonUIElements.defaultSubmitButton(text: "+1", backgroundColor: UIColor.init(red: 73.0/255, green: 116.0/255, blue: 171.0/255, alpha: 0.65))
        plusOneButton.addTarget(self, action: #selector(onPlusOneClick), for: .touchUpInside)
        
        showAllButton = CommonUIElements.defaultSubmitButton(text: "Все", backgroundColor: UIColor.init(red: 73.0/255, green: 116.0/255, blue: 171.0/255, alpha: 0.65))
        showAllButton.addTarget(self, action: #selector(onShowAllClick), for: .touchUpInside)
        
        let view = UIView()
        view.addSubview(plusOneButton)
        view.addSubview(showAllButton)
        
        plusOneButton.anchor(top: view.topAnchor, left: nil, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 10, paddingLeft: 0, paddingBottom: 10, paddingRight: 27.5, width: 0, height: 0)
        showAllButton.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: nil, paddingTop: 10, paddingLeft: 27.5, paddingBottom: 10, paddingRight: 0, width: 0, height: 0)
        
        plusOneButton.widthAnchor.constraint(equalTo: showAllButton.widthAnchor).isActive = true
        showAllButton.widthAnchor.constraint(greaterThanOrEqualTo: view.widthAnchor, multiplier: 0.15).isActive = true
        
        return view
    }()
    
    /// Label for displaying index number of current card
    lazy var cardNumberLabel: UILabel = {
        let cardNumberLabel = UILabel(); cardNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        cardNumberLabel.font = UIFont.systemFont(ofSize: 20)
        cardNumberLabel.textAlignment = .center
        
        return cardNumberLabel
    }()
    
    /// Label for displaying number of translations in current card
    lazy var translationsNumberLabel: UILabel = {
        let translationsNumberLabel = UILabel(); translationsNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        translationsNumberLabel.font = UIFont.systemFont(ofSize: 20)
        translationsNumberLabel.textAlignment = .center
        
        return translationsNumberLabel
    }()
    
    /**
     Creates new `LearnView`
     - Parameter dataSource: `tableView`'s data source and delegate
     - Parameter actionsDelegate: instance for reacting on actions buttons clicks
     - Parameter scrollViewDelegate: instance for reacting on scrolling in tableView scrolling
     */
    init(dataSource: ILearnControllerTableViewDataSource, actionsDelegate: ILearnControllerActionsDelegate?, scrollViewDelegate: UIScrollViewDelegate?) {
        self.dataSource = dataSource
        self.actionsDelegate = actionsDelegate
        self.scrollViewDelegate = scrollViewDelegate
        super.init(frame: .zero)
        
        self.addSubview(self.contentView)
        self.contentView.anchor(top: self.topAnchor, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        setHeaderData()
    }
    
    /// Forbidden to instantiate from Storyboard
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// +1 button click listener
    @objc func onPlusOneClick() {
        self.plusOneButton.flash(toValue: 0.5, duration: 0.3)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            self.actionsDelegate?.onPlusOne()
        }
    }
        
    /// All button click listener
    @objc func onShowAllClick() {
        self.showAllButton.flash(toValue: 0.5, duration: 0.3)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            self.actionsDelegate?.onShowAll()
        }
    }
    
    /// Wrapper-view for all views on screen
    lazy var contentView: UIView = {
        let view = UIView()
        view.addSubview(self.headerView)
        view.addSubview(self.collectionContainerView)
        
        self.headerView.anchor(top: view.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        self.headerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        self.headerView.widthAnchor.constraint(greaterThanOrEqualTo: view.widthAnchor, constant: -40).isActive = true
        self.headerView.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, constant: 0).isActive = true
      
        
        self.collectionContainerView.anchor(top: self.headerView.bottomAnchor, left: nil, bottom: view.bottomAnchor, right: nil, paddingTop: 10, paddingLeft: 0, paddingBottom: 20, paddingRight: 0, width: 0, height: 0)
        self.collectionContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        self.collectionContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: 0).isActive = true
        
        return view
    }()
    
    /// Scroll view with all view inside it
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        scrollView.alwaysBounceHorizontal = false
        scrollView.delegate = scrollViewDelegate
        scrollView.showsHorizontalScrollIndicator = false
        
        scrollView.addSubview(self.contentView)
        
        self.contentView.anchor(top: scrollView.topAnchor, left: nil, bottom: scrollView.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        self.contentView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        self.contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -20).isActive = true
        
        return scrollView
    }()
}

extension LearnView: ILearnControllerDataSourceReactor {
    func showController(controller: UIViewController) {
        self.parentViewController?.navigationController?.pushViewController(controller, animated: true)
    }
    
    func onUpdateWholeView() {
        self.tableView.reloadData()
        
        hideControlsIfNeeded()
        self.setHeaderData()
    }
    
    func addItems(indexPaths: [IndexPath]) {
        //UIView.performWithoutAnimation {
        self.tableView.reloadData()
        
        hideControlsIfNeeded()
        //}
    }
    
    func hideControlsIfNeeded() {
        if self.dataSource.viewModel.getItems(currCardPos: self.dataSource.state.itemNumber).count == self.dataSource.state.translationsShown {
            UIView.animate(withDuration: 0.6, animations: {
                self.plusOneButton.alpha = 0
                self.showAllButton.alpha = 0
            }) { (_) in
                self.collectionContainerView.shadowView.isAnimatable = true
                self.collectionContainerView.shadowView.animationDuration = 0.5
                UIView.animate(withDuration: 0.5) {
                    self.plusOneButton.isHidden = true
                    self.showAllButton.isHidden = true
                    self.controlsView.isHidden = true
                } completion: { (_) in
                    self.collectionContainerView.shadowView.isAnimatable = false
                }
            }
        } else if (self.controlsView.isHidden) {
            self.collectionContainerView.shadowView.isAnimatable = true
            self.collectionContainerView.shadowView.animationDuration = 0.5
            UIView.animate(withDuration: 0.5) {
                self.plusOneButton.isHidden = false
                self.showAllButton.isHidden = false
                self.controlsView.isHidden = false
            } completion: { (_) in
                UIView.animate(withDuration: 0.6) {
                    self.plusOneButton.alpha = 1
                    self.showAllButton.alpha = 1
                } completion: { (_) in
                    self.collectionContainerView.shadowView.isAnimatable = false
                }
            }
        }
    }
}

/// Class for generating `LearnView`s
class LearnViewGenerator {
    /**
     Generates new `LearnView`
     - Parameter dataSource: `tableView`'s data source and delegate
     - Parameter actionsDelegate: instance for reacting on actions buttons clicks
     - Parameter scrollViewDelegate: instance for reacting on scrolling in tableView scrolling
     */
    func generate(dataSource: ILearnControllerTableViewDataSource, actionsDelegate: ILearnControllerActionsDelegate?, scrollViewDelegate: UIScrollViewDelegate?) -> LearnView {
        return LearnView(dataSource: dataSource, actionsDelegate: actionsDelegate, scrollViewDelegate: scrollViewDelegate)
    }
}

extension UIResponder {
    public var parentViewController: UIViewController? {
        return next as? UIViewController ?? next?.parentViewController
    }
}
