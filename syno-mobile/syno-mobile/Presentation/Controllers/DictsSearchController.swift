import Foundation
import UIKit

class DictsSearchController: UIViewController {
    private var model: IDictsSearchControllerModel
    var searchController: UISearchController! {
        didSet {
            self.searchController.delegate = self
            self.searchController.searchResultsUpdater = self
            self.searchController.searchBar.delegate = self
        }
    }
    var realController: UIViewController!
    
    lazy var processingSaveView: SavingProcessView = {
        let view = SavingProcessView()
        view.setText(text: "Делимся..")
        
        return view
    }()
    
    private let bottomInset: CGFloat = 10
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let colView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        colView.alwaysBounceVertical = true
        colView.backgroundColor = .white
        colView.allowsSelection = true
        colView.delegate = self.model.dataSource
        colView.dataSource = self.model.dataSource
        
        colView.contentInset = UIEdgeInsets(top: 30, left: 15, bottom: bottomInset, right: 15)
        
        colView.register(DictionaryCollectionViewCell.self, forCellWithReuseIdentifier: DictionaryCollectionViewCell.cellId)
        colView.register(CardCollectionViewCell.self, forCellWithReuseIdentifier: CardCollectionViewCell.cellId)
        colView.register(DictsSearchDictNameHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: DictsSearchDictNameHeader.headerId)
        return colView
    }()
    
    init(model: IDictsSearchControllerModel) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
        self.model.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(collectionView)
        collectionView.anchor(top: self.view.topAnchor, left: self.view.leftAnchor, bottom: self.view.bottomAnchor, right: self.view.rightAnchor)
        
        self.addKeyboardObservers(showSelector: #selector(showKeyboard(notification:)), hideSelector: #selector(hideKeyboard(notification:)))
        let gr = UITapGestureRecognizer(target: self, action: #selector(clearKeyboard))
        gr.cancelsTouchesInView = false
        self.view.addGestureRecognizer(gr)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension DictsSearchController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        updateSearchResults(for: searchController)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        updateSearchResults(for: searchController)
    }
}

extension DictsSearchController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        self.model.updateState(searchString: searchController.searchBar.text ?? "", mode: searchController.searchBar.selectedScopeButtonIndex, doFetch: true)
        self.collectionView.reloadData()
    }
}

extension DictsSearchController: UISearchControllerDelegate {
    
}

extension DictsSearchController: DictsSearchControllerModelDelegate {
    func showController(controller: UIViewController, completion: ((UIViewController) -> Void)?) {
        //searchController.navigationController
        self.realController.navigationController?.pushViewController(controller, animated: true)
        completion?(self.realController)
    }
    
    func onShowSharingProcessView() {
        processingSaveView.showSavingProcessView(sourceView: self)
    }
    
    func onShowSharingResultView(result: ShowSharingResultViewConfiguration) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.processingSaveView.dismissSavingProcessView()
        }
        
        DictShareHelper.showSharingResultView(controller: self, result: result)
    }
    
    @objc func showKeyboard(notification: NSNotification) {
        if let keyboardHeight = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height {
            let tabbarHeight = self.realController.tabBarController?.tabBar.frame.height ?? 0
            self.collectionView.contentInset.bottom = keyboardHeight + bottomInset - tabbarHeight
            self.collectionView.verticalScrollIndicatorInsets = .init(top: 0, left: 0, bottom: keyboardHeight - tabbarHeight, right: 0)
        }
    }
    
    /// Shifts view back when keyboard is hidden
    @objc func hideKeyboard(notification: NSNotification) {
        Logger.log("Hide")
        if let keyboardHeight = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height {
            self.collectionView.contentInset.bottom = bottomInset
            self.collectionView.verticalScrollIndicatorInsets = .init(top: 0, left: 0, bottom: 0, right: 0)
        }
    }
    
    @objc func clearKeyboard() {
        self.view.window?.endEditing(false)
    }
}

