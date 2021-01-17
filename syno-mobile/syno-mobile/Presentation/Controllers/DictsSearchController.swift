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
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let colView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        colView.alwaysBounceVertical = true
        colView.backgroundColor = .white
        colView.delegate = self.model.dataSource
        colView.dataSource = self.model.dataSource
        
        colView.contentInset = UIEdgeInsets(top: 30, left: 15, bottom: 0, right: 15)
        
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
}

