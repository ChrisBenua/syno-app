import Foundation
import UIKit

/// Controller for displaying translations in edit mode
class TranslationsCollectionViewController: UIViewController {
    /// Scroll view to position where it was before keyboard was shown
    func scrollToTop() {
        scrollToTop(self.scrollView, animated: true)
    }
    /// Position, where view was before keyboard was shown
    var prevOffset: CGPoint?
    /// Flag for indicating if keyboard is shown
    var isKeyboardShown: Bool = false
    
    /**
     Scroll view to its previous position before showing keyboard
     - Parameter scrollView: scrollView to return to previous position
     - Parameter animated: should animate scrolling
     */
    func scrollToTop(_ scrollView: UIScrollView, animated: Bool = true) {
        self.scrollView.contentInset.bottom = 0
        if let prevOffset = prevOffset {
            scrollView.setContentOffset(prevOffset, animated: true)
        } else {
            if #available(iOS 11.0, *) {
                let expandedBar = (navigationController?.navigationBar.frame.height ?? 64.0 > 44.0)
                let largeTitles = (navigationController?.navigationBar.prefersLargeTitles) ?? false
                let offset: CGFloat = (largeTitles && !expandedBar) ? 52: 0
                Logger.log("Setting content offsest")
                scrollView.setContentOffset(CGPoint(x: 0, y: -(scrollView.adjustedContentInset.top + offset)), animated: animated)
            } else {
                scrollView.setContentOffset(CGPoint(x: 0, y: -scrollView.contentInset.top), animated: animated)
            }
        }
    }
    
    /// Service responsible for formatting data for table view
    var dataSource: ITranslationControllerDataSource
    
    /// Process view to show when saving changes
    lazy var processingSaveView: SavingProcessView = {
        let view = SavingProcessView()
        view.setText(text: "Saving")
        
        return view
    }()
    
    
    /// View with actions buttons
    lazy var controlsView: UIView = {
        let addButton = UIButton(type: .custom)
        addButton.setBackgroundImage(#imageLiteral(resourceName: "Component 4"), for: .normal)
        
        addButton.addTarget(self, action: #selector(onAddAnswerButton), for: .touchUpInside)
        
        let view = UIView()
        view.addSubview(addButton)

        addButton.anchor(top: view.topAnchor, left: nil, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 25, width: 0, height: 0)
        addButton.heightAnchor.constraint(equalTo: addButton.widthAnchor, multiplier: 1).isActive = true
        addButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        return view
    }()
    
    /// `addButton` click listener
    @objc func onAddAnswerButton() {
        self.dataSource.add()
    }
    
    /// table view for CRUD operations with Translations
    lazy var tableView: UITableView = {
        let tableView = PlainTableView()
        
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        
        tableView.alwaysBounceVertical = false
        tableView.isScrollEnabled = false
        
        tableView.backgroundColor = UIColor.clear
        
        tableView.delegate = self.dataSource
        tableView.dataSource = self.dataSource
        
        tableView.separatorStyle = .none
        
        tableView.contentInset = UIEdgeInsets(top: 30, left: 0, bottom: 10, right: 0)
        
        tableView.register(TranslationTableViewCell.self, forCellReuseIdentifier: TranslationTableViewCell.cellId())
        
        return tableView
    }()
    
    /// Wrapper-view for `tableView` and `controlsView`
    lazy var collectionContainerView: UIView = {
        let view = BaseShadowView()
        view.shadowView.shadowOffset = CGSize(width: 0, height: 4)

        view.containerViewBackgroundColor = UIColor(red: 247.0/255, green: 247.0/255, blue: 247.0/255, alpha: 1)
        view.cornerRadius = 20
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(self.tableView)
        view.addSubview(self.controlsView)
        
        self.controlsView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        self.tableView.anchor(top: self.controlsView.bottomAnchor, left: nil, bottom: view.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 10, paddingRight: 0, width: 0, height: 0)
        self.tableView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -30).isActive = true
        self.tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        return view
    }()
    
    /// Header label
    lazy var collectionViewHeader: UIView = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .regular)
        label.text = "Переводы"
        label.textAlignment = .center
        
        return label
    }()
    
    /// View for translated word
    lazy var translatedWordHeader: UIView = {
        let header = TranslatedWordView()
        header.translatedWordLabel.text = self.dataSource.viewModel.sourceCard.translatedWord
        header.translatedWordLabel.addTarget(self, action: #selector(onTranslatedWordChanded(_:)), for: .editingChanged)
        
        return header
    }()
    
    /// `translatedWordHeader` editing listener
    @objc func onTranslatedWordChanded(_ textField: UITextField) {
        self.dataSource.updateTranslatedWord(newTranslatedWord: textField.text)
    }
    
    /// scrollView that contains all views
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        scrollView.alwaysBounceHorizontal = false
        scrollView.delegate = self
        scrollView.showsHorizontalScrollIndicator = false
        
        scrollView.addSubview(self.collectionContainerView)
        scrollView.addSubview(self.collectionViewHeader)
        scrollView.addSubview(self.translatedWordHeader)
        
        self.translatedWordHeader.anchor(top: scrollView.contentLayoutGuide.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        self.translatedWordHeader.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        self.translatedWordHeader.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: 1, constant: -30).isActive = true
        
        self.collectionViewHeader.anchor(top: self.translatedWordHeader.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        self.collectionViewHeader.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        self.collectionViewHeader.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        
        return scrollView
    }()

    /**
     Creates new `TranslationsCollectionViewController`
     - Parameter dataSource: service responsible for deliviring data for `tableView`
     */
    init(dataSource: ITranslationControllerDataSource) {
        self.dataSource = dataSource
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Карточки"
        self.view.backgroundColor = .white
        
        let allViewTapGestureReco = UITapGestureRecognizer(target: self, action: #selector(clearKeyboard(_:)))
        view.addGestureRecognizer(allViewTapGestureReco)
        allViewTapGestureReco.cancelsTouchesInView = false
        allViewTapGestureReco.delegate = self
        
        self.addKeyboardObservers(showSelector: #selector(showKeyboard(notification:)), hideSelector: #selector(hideKeyboard(notification:)))
        
        if #available(iOS 13, *) {} else {
            let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressOnCollectionView(gesture:)))
            longPress.delaysTouchesBegan = true
            self.tableView.addGestureRecognizer(longPress)
        }
        
        self.view.addSubview(scrollView)
        scrollView.anchor(top: self.view.topAnchor, left: self.view.leftAnchor, bottom: self.view.bottomAnchor, right: self.view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: UIScreen.main.bounds.width, height: 0)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Сохранить", style: .plain, target: self, action: #selector(onSaveButtonPressed))
        
        self.collectionContainerView.anchor(top: self.collectionViewHeader.bottomAnchor, left: nil, bottom: scrollView.bottomAnchor, right: nil, paddingTop: 10, paddingLeft: 0, paddingBottom: 20, paddingRight: 0, width: 0, height: 0)
       self.collectionContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
       self.collectionContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -30).isActive = true
    }
    
    @objc func handleLongPressOnCollectionView(gesture: UILongPressGestureRecognizer) {
        let p = gesture.location(in: self.tableView)

        if let indexPath = self.tableView.indexPathForRow(at: p) {
            let alert = UIAlertController(title: "Действия", message: nil, preferredStyle: .actionSheet)
            let deleteAction = UIAlertAction(title: "Удалить", style: .destructive) { (_) in
                self.dataSource.deleteAt(ind: indexPath.row)
            }
            
            let cancelAction = UIAlertAction(title: "Отмена", style: .cancel) { (_) in
                alert.dismiss(animated: true, completion: nil)
            }
            
            alert.addAction(deleteAction)
            alert.addAction(cancelAction)
            
            self.present(alert, animated: true, completion: nil)
        } else {
            print("couldn't find index path")
        }
    }
    
    /// Save button click listener
    @objc func onSaveButtonPressed() {
        self.processingSaveView.showSavingProcessView(sourceView: self)
        self.dataSource.save {
            DispatchQueue.main.async {
                let timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { (timer) in
                    self.processingSaveView.dismissSavingProcessView()
                    self.navigationController?.popViewController(animated: true)
                }
                
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TranslationsCollectionViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.contentOffset.x = 0
    }
}

extension TranslationsCollectionViewController {
    /**
     Keyboard showing listener
     - Parameter notification: contains inner data about notification
     */
    @objc func showKeyboard(notification: NSNotification) {
        isKeyboardShown = true
        if let keyboardHeight = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height {
            Logger.log("keyboard height:\(keyboardHeight)")
            prevOffset = self.scrollView.contentOffset
            if let lastFocusedPoint = self.dataSource.getLastFocusedPoint() {
                Logger.log("Last Focused Point: \(lastFocusedPoint)")
                let point = self.tableView.convert(lastFocusedPoint, to: self.view)
                Logger.log("Converted Point: \(point)")
                let neededShift = UIScreen.main.bounds.height - point.y - keyboardHeight - 40
                Logger.log("Needed shift: \(neededShift)")
                if (neededShift < 0) {
                    Logger.log(scrollView.contentOffset.debugDescription)
                    self.scrollView.contentInset.bottom = -neededShift + scrollView.contentOffset.y + 20
                    self.scrollView.setContentOffset(CGPoint(x: 0, y: -neededShift + scrollView.contentOffset.y), animated: true)
                }
            }
        }
    }
    
    /**
    Keyboard hiding listener
    - Parameter notification: contains inner data about notification
    */
    @objc func hideKeyboard(notification: Notification) {
        Logger.log("Hide")
        isKeyboardShown = false
    }
    
    /// Ends editing in whole view
    @objc func clearKeyboard(_ sender: UITapGestureRecognizer) {
        Logger.log(sender.location(in: self.view).debugDescription)
        let wasKeyboardShow = self.isKeyboardShown
        view.endEditing(true)
        if wasKeyboardShow {
            self.scrollToTop()
        }
    }
}

extension TranslationsCollectionViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}

